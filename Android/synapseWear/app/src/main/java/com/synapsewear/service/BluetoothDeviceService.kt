package com.synapsewear.service

import android.os.Handler
import com.polidea.rxandroidble2.RxBleDevice
import com.synapsewear.app.SynapseWearApplication
import com.synapsewear.data.device.SynapseValues
import com.synapsewear.data.device.SynapseWearDevice
import com.synapsewear.data.enums.FirmwareUpdateStatus
import com.synapsewear.data.enums.StatusState
import com.synapsewear.data.firmware.FirmwareVersion
import com.synapsewear.data.settings.SynapseWearSettings
import com.synapsewear.utils.*
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.addTo
import io.reactivex.rxkotlin.subscribeBy
import io.reactivex.subjects.PublishSubject
import timber.log.Timber
import java.util.*
import kotlin.collections.ArrayList


class BluetoothDeviceService(
    private val sharedPrefRepository: SharedPreferencesRepository,
    private val connectionService: BluetoothDeviceConnectionService,
    private val uploadService: UploadService,
    private val oscService: OscService
) {

    val deviceSubject = PublishSubject.create<SynapseWearDevice>()
    val deviceConnectionSubject = PublishSubject.create<SynapseWearDevice>()
    val deviceFirmwareUpdateSubject = PublishSubject.create<FirmwareUpdateStatus>()

    private val compositeDisposable = CompositeDisposable()
    private val connectionDisposable = CompositeDisposable()

    private var connectedDevice: SynapseWearDevice? = null

    var deviceSettings = SynapseWearSettings()

    private var currentNotification = ArrayList<Byte>()
    private var currentNotificationLength = 0

    var firmwareVersionUpdate: FirmwareVersion? = null
    private var isDeviceInOtaMode = false
    private var firmwareList: List<ByteArray>? = null

    fun associateWithDevice() {
        connectionService.writeReadDataToDevice(I6_COMMAND_ASSOCIATE_WITH_DEVICE)
            ?.flatMap { byteArray ->
                if (byteArray.size == 9 && byteArray[0] == VALUE_RESPONSE_OK) {

                    sharedPrefRepository.saveDeviceMacAddress(getConnectedDevice().macAddress!!)
                    sharedPrefRepository.saveDeviceToken(byteArray)

                    connectionService.deviceToken = byteArray

                    connectionService.writeReadDataToDevice(COMMAND_SAVE_TOKEN)
                } else {
                    connectionService.writeReadDataToDevice(I9_COMMAND_RESET_ASSOCIATION)
                }
            }
            ?.subscribe({
                if (connectionService.deviceToken != null && !it.contentEquals(ARRAY_RESPONSE_ERROR)) {
                    deviceSubject.onNext(getConnectedDevice())
                    initDevice()
                } else {
                    associateWithDevice()
                }

            }, {
                establishConnectionWithSavedDevice()
            })?.let { compositeDisposable.add(it) }
    }

    private fun onAssociationRequired(shouldRefreshToken: Boolean) {
        sharedPrefRepository.saveDeviceMacAddress(getConnectedDevice().macAddress!!)

        if (shouldRefreshToken || sharedPrefRepository.getSavedDeviceToken(getConnectedDevice().macAddress!!) == null
        ) {
            getConnectedDevice().status = StatusState(StatusState.PAIRING)
            deviceConnectionSubject.onNext(connectedDevice!!)
        } else {
            connectionService.deviceToken = sharedPrefRepository.getSavedDeviceToken(getConnectedDevice().macAddress)
            initDevice()
        }
    }

    private fun initDevice() {
        connectedDevice?.status = StatusState(StatusState.ASSOCIATED)

        connectedDevice?.macAddress?.let {
            uploadService.init(it)
        }

        isDeviceInOtaMode = false
        connectedDevice?.status = StatusState(StatusState.READING_DATA)
        deviceConnectionSubject.onNext(connectedDevice!!)
    }


    fun establishConnectionWithSavedDevice() =
        sharedPrefRepository.getSavedDeviceMacAddress()?.let {
            val rxBleDevice = connectionService.getDevice(it)
            establishConnectionWithDevice(rxBleDevice)
        }


    fun establishConnectionWithDevice(rxBleDevice: RxBleDevice) {
        compositeDisposable.clear()
        connectionService.deviceToken = null
        if (connectionService.connectedRxBleDevice != null) {
            connectionService.disconnectTriggerSubject.onNext(Unit)
        }
        connectToDevice(rxBleDevice)

    }

    private fun connectToDevice(rxBleDevice: RxBleDevice) {

        deviceConnectionSubject.onNext(getTargetedDevice(rxBleDevice))

        connectionService.prepareConnectionObservable(rxBleDevice)
            ?.subscribe({
                connectedDevice = SynapseWearDevice(
                    macAddress = rxBleDevice.macAddress,
                    status = StatusState(StatusState.ASSOCIATED)
                )
                onAssociationRequired(false)

            }, { throwable ->
                Timber.e(throwable)
            })?.let { connectionDisposable.add(it) }
    }

    fun updateDeviceSettings(isInBackground: Boolean) {
        sharedPrefRepository.getSettings()?.let {
            deviceSettings = it
        }

        oscService.changeSettings(deviceSettings.oscSettings)
        uploadService.changeSettings(deviceSettings.uploadSettings)

        compositeDisposable.clear()

        if (connectionService.deviceToken == null) return

        connectedDevice?.status = StatusState(StatusState.ASSOCIATED)

        val sensorsArrayToSend = deviceSettings.sensorsValues.toByteArray()
        sensorsArrayToSend[0] = I4_COMMAND_CHANGE_SENSORS

        connectionService.stopSendingData()
            ?.flatMap { connectionService.writeReadDataToDevice(I5_COMMAND_CHECK_FIRMWARE_VERSION) }
            ?.flatMap { firmwareByteArray ->
                FirmwareVersion.fromByteArray(firmwareByteArray)?.let { connectedDevice?.firmwareVersion = it }
                connectionService.writeReadDataToDevice(sensorsArrayToSend)
            }?.flatMap {
                connectionService.writeReadDataToDevice(
                    deviceSettings.intervalTime.getAppCommand(
                        isInBackground
                    )
                )
            }?.flatMap { connectionService.startSendingData() }?.subscribeBy(onSuccess = { response ->
                if (response == null || response.contentEquals(ARRAY_RESPONSE_ERROR)) {
                    onAssociationRequired(true)
                } else {
                    readData()
                }
            })?.addTo(compositeDisposable)

    }

    private fun readData() {
        connectionService.readDeviceNotifications()?.subscribe { byteArray ->
            if (byteArray.size > 1) {
                val byteList = byteArray.toList()

                if (byteList.slice(0..1).toByteArray().contentEquals(VALUE_DEVICE_HEADER)) {
                    currentNotificationLength = byteList[2].toInt()
                    currentNotification.clear()
                    currentNotification.addAll(byteList)
                } else {
                    currentNotification.addAll(byteList)
                }
                if (currentNotification.size >= currentNotificationLength) {
                    connectedDevice?.synapseValues = SynapseValues.fromByteArray(currentNotification.toByteArray())
                    currentNotification.clear()

                    oscService.sendData(connectedDevice?.synapseValues)
                    uploadService.addValue(connectedDevice?.synapseValues)
                    deviceSubject.onNext(connectedDevice!!)
                }
            } else {
                associateWithDevice()
            }

        }?.let { compositeDisposable.add(it) }
    }

    fun startFirmwareUpdate(firmwareVersion: FirmwareVersion) {
        firmwareVersionUpdate = firmwareVersion
        deviceFirmwareUpdateSubject.onNext(FirmwareUpdateStatus(FirmwareUpdateStatus.DOWNLOADING_UPDATE_FILE))
        prepareDeviceForFirmwareUpdate()
    }

    private fun prepareDeviceForFirmwareUpdate() {
        compositeDisposable.clear()

        connectionService.prepareForFirmwareUpdate()?.subscribe({
            isDeviceInOtaMode = true
            uploadFirmwareFile()
        }, {
            deviceFirmwareUpdateSubject.onNext(FirmwareUpdateStatus(FirmwareUpdateStatus.ERROR))
        }
        )?.let { compositeDisposable.add(it) }
    }

    fun setFirmwareArray(firmwareArray: List<ByteArray>) {
        firmwareList = firmwareArray
        uploadFirmwareFile()
    }

    private fun uploadFirmwareFile() {
        var elementsSend = 0
        deviceFirmwareUpdateSubject.onNext(FirmwareUpdateStatus(elementsSend))

        if (isDeviceInOtaMode && firmwareList != null) {

            connectionService.sendFirmwareArray(firmwareList!!)
                ?.doOnNext {
                    elementsSend++
                    deviceFirmwareUpdateSubject.onNext(FirmwareUpdateStatus((elementsSend * 100) / firmwareList!!.size))
                }
                ?.subscribeBy(onError = {
                    deviceFirmwareUpdateSubject.onNext(FirmwareUpdateStatus(FirmwareUpdateStatus.ERROR))
                })?.let { compositeDisposable.add(it) }
        }
    }

    fun getConnectedDevice() = connectedDevice ?: SynapseWearDevice(
        sharedPrefRepository.getSavedDeviceMacAddress()
    )

    fun getConnectedRxBleDevice() = connectedDevice?.macAddress?.let {
        connectionService.getDevice(it)
    }

    private fun getTargetedDevice(rxBleDevice: RxBleDevice) = SynapseWearDevice(
        macAddress = rxBleDevice.macAddress,
        status = StatusState(StatusState.CONNECTING)
    )

    companion object {
        val instance by lazy {
            BluetoothDeviceService(
                SynapseWearApplication.sharedPreferencesRepository,
                BluetoothDeviceConnectionService.instance,
                SynapseWearApplication.uploadService,
                SynapseWearApplication.oscService
            )
        }
    }
}

