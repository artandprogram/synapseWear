package com.synapsewear.app.settings.firmware

import com.synapsewear.data.firmware.FirmwareResponse
import com.synapsewear.service.BluetoothDeviceService
import com.synapsewear.service.NetworkService
import com.synapsewear.utils.FIRMWARE_BASE_URL
import com.synapsewear.utils.FIRMWARE_LIST_PATH
import com.synapsewear.viewmodel.BaseLoadingViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import timber.log.Timber
import java.io.BufferedReader
import java.io.File
import java.io.FileReader

class FirmwareViewModel(
    private val bluetoothDeviceService: BluetoothDeviceService,
    private val networkService: NetworkService
) : BaseLoadingViewModel() {

    val deviceSettings = bluetoothDeviceService.deviceSettings
    val firmwareListAdapter = FirmwareAdapter()

    fun getFirmwareVersions(disposable: CompositeDisposable) {
        isLoading.set(true)

        var firmwareURL = deviceSettings.firmwareUrl
        if (firmwareURL.isEmpty()) firmwareURL = FIRMWARE_LIST_PATH

        firmwareListAdapter.clearList()

        disposable.add(
            networkService.createGetRequest(firmwareURL, FirmwareResponse::class.java)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    firmwareListAdapter.addFirmwareVersions(it.firmwareList)
                    isLoading.set(false)
                }, { throwable ->
                    Timber.e(throwable)
                    isLoading.set(false)
                })
        )
    }

    fun downloadUpdateFile(disposable: CompositeDisposable, file: File) {
        disposable.add(
            networkService.downloadFile(
                downloadURL = FIRMWARE_BASE_URL + "/" + bluetoothDeviceService.firmwareVersionUpdate?.hexFileName,
                outFile = file
            )
                .subscribe({ firmwareFile ->
                    if (firmwareFile.canRead()) {
                        val bufferedReader = BufferedReader(FileReader(firmwareFile))
                        val firmwareArray = bufferedReader.readLines()

                        val listToReturn = ArrayList<ByteArray>()

                        firmwareArray.forEach {
                            val stringToReturn = it.removeRange(0..0)
                            val byteArray = ByteArray(stringToReturn.length / 2 + 1)

                            stringToReturn.chunked(2).forEachIndexed { index, byte ->
                                byteArray[index] = byte.toInt(16).toByte()
                            }

                            listToReturn.add(byteArray)
                        }
                        bluetoothDeviceService.setFirmwareArray(listToReturn)
                        firmwareFile.delete()
                    }
                }, { throwable ->
                    Timber.e(throwable)
                })
        )
    }

    fun getFirmwareUpdateSubject() = bluetoothDeviceService.deviceFirmwareUpdateSubject

}