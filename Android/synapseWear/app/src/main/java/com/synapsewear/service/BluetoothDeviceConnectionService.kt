package com.synapsewear.service

import android.bluetooth.BluetoothGattCharacteristic
import com.jakewharton.rx.ReplayingShare
import com.polidea.rxandroidble2.RxBleClient
import com.polidea.rxandroidble2.RxBleConnection
import com.polidea.rxandroidble2.RxBleDevice
import com.synapsewear.app.SynapseWearApplication
import com.synapsewear.utils.*
import io.reactivex.Observable
import io.reactivex.Single
import io.reactivex.rxkotlin.toObservable
import io.reactivex.subjects.PublishSubject
import timber.log.Timber
import java.util.concurrent.TimeUnit
import kotlin.experimental.and


class BluetoothDeviceConnectionService(
    private val rxBleClient: RxBleClient
) {

    private lateinit var connectionObservable: Observable<RxBleConnection>
    var connectedRxBleDevice: RxBleDevice? = null

    var deviceToken: ByteArray? = null

    var disconnectTriggerSubject = PublishSubject.create<Unit>()

    fun prepareConnectionObservable(rxBleDevice: RxBleDevice): Observable<BluetoothGattCharacteristic>? {
        connectedRxBleDevice = rxBleDevice

        connectionObservable = rxBleDevice
            .establishConnection(false)
            .compose(ReplayingShare.instance())
            .takeUntil(disconnectTriggerSubject)
            .doOnError { throwable ->
                Timber.e(throwable)
            }
            .retry(RETRY_TIMES_VALUE)

        return connectionObservable
            .flatMapSingle { it.discoverServices() }
            .flatMapSingle { it.getCharacteristic(SYNAPSE_WEAR_DEFAULT_SEND_UUID) }
    }

    fun writeReadDataToDevice(data: ByteArray): Single<ByteArray>? {
        val dataArray = convertRequestArray(data)
        Timber.d("Sending %s", dataArray.contentToHexString())

        return connectionObservable
            .firstOrError()
            .flatMap { rxBleConnection ->
                rxBleConnection.writeCharacteristic(SYNAPSE_WEAR_DEFAULT_SEND_UUID, dataArray)
                    .delay(DELAY_READ_WRITE_MIN, TimeUnit.MILLISECONDS)
                    .flatMap {
                        rxBleConnection.readCharacteristic(SYNAPSE_WEAR_DEFAULT_RECEIVE_UUID)
                    }
                    .doOnSuccess { Timber.d("Received %s", it.contentToHexString()) }
                    .doOnError { throwable -> Timber.e(throwable.toString()) }
            }
    }

    private fun convertRequestArray(data: ByteArray): ByteArray {
        val convertedArray = if (data.size > BYTE_ARRAY_NO_HEADER_MAX_LENGTH) {
            val list = data.toMutableList()
            list.run {
                addAll(0, VALUE_DEVICE_HEADER.toList())
                add(2, VALUE_RESPONSE_OK)
                addAll(VALUE_DEVICE_HEADER.toList())
                add(2, (this.size + 1).toByte())
            }
            list.toByteArray()
        } else data

        return convertedArray.map { it and 0xFF.toByte() }.toByteArray()
    }


    fun startSendingData(): Single<ByteArray>? {
        return getTokenRequest(I1_COMMAND_START_SENDING_DATA)?.let { deviceToken ->
            connectionObservable
                .firstOrError()
                .flatMap { writeReadDataToDevice(deviceToken) }
        }
    }

    fun stopSendingData(): Single<ByteArray>? {
        return getTokenRequest(I2_COMMAND_STOP_SENDING_DATA)?.let { request ->
            connectionObservable
                .firstOrError()
                .flatMap { writeReadDataToDevice(request) }
                .delay(DELAY_STOP_SENDING_DATA_RESUME, TimeUnit.MILLISECONDS)
        }
    }

    fun prepareForFirmwareUpdate(): Single<ByteArray>? {
        return stopSendingData()
            ?.flatMap {
                getTokenRequest(I7_COMMAND_UPDATE_FIRMWARE)?.let {
                    writeReadDataToDevice(it)
                }
            }
            ?.flatMap {
                if (it.contentEquals(ARRAY_RESPONSE_OK)) {
                    Single.just(it)
                } else {
                    connectionObservable
                        .firstOrError()
                        .flatMap { rxBleConnection ->
                            rxBleConnection.writeCharacteristic(
                                SYNAPSE_WEAR_DEFAULT_SEND_UUID,
                                I8_COMMAND_FORCE_UPDATE_FIRMWARE
                            )
                        }
                }
            }
    }

    fun sendFirmwareArray(arrayToSend: List<ByteArray>): Observable<ByteArray>? {
        return stopSendingData()
            ?.flatMapObservable {
                arrayToSend.toObservable()
                    .flatMap {
                        connectionObservable
                            .flatMap { rxBleConnection ->
                                val byteArray = convertRequestArray(it)
                                Timber.d("Sending %s", byteArray.contentToHexString())
                                rxBleConnection.writeCharacteristic(SYNAPSE_WEAR_DEFAULT_SEND_UUID, byteArray)
                                    .delay(DELAY_WRITE_FIRMWARE_LINE, TimeUnit.MILLISECONDS)
                                    .toObservable()
                            }
                    }
            }
    }

    fun readDeviceNotifications(): Observable<ByteArray>? {
        return connectionObservable
            .flatMap { it.setupNotification(SYNAPSE_WEAR_DEFAULT_RECEIVE_UUID) }
            .flatMap { notificationObservable -> notificationObservable }
            .doOnNext { Timber.d("Received ${it.contentToHexString()}") }
    }

    private fun getTokenRequest(byteToAppend: Byte) =
        deviceToken?.let {
            val request = it
            request[0] = byteToAppend
            request
        }


    fun getDevice(macAddress: String): RxBleDevice = rxBleClient.getBleDevice(macAddress)

    companion object {
        val instance by lazy {
            BluetoothDeviceConnectionService(
                SynapseWearApplication.rxBleClient
            )
        }

        const val RETRY_TIMES_VALUE = 5L
    }
}