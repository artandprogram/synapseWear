package com.synapsewear.app.status

import androidx.databinding.ObservableField
import androidx.lifecycle.ViewModel

import com.synapsewear.data.device.SynapseWearDevice
import com.synapsewear.data.enums.StatusState
import com.synapsewear.data.settings.SynapseWearSettings
import com.synapsewear.service.BluetoothDeviceService
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.plusAssign

class StatusViewModel(
    private val bluetoothDeviceService: BluetoothDeviceService
) : ViewModel() {

    val connectedDevice = ObservableField<SynapseWearDevice>(bluetoothDeviceService.getConnectedDevice())

    private val disposable = CompositeDisposable()


    val convertedTemperature = ObservableField<Float?>()


    val deviceSettings = ObservableField<SynapseWearSettings>(bluetoothDeviceService.deviceSettings)

    init {
        disposable +=
            bluetoothDeviceService.deviceSubject
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    connectedDevice.set(it)
                    deviceSettings.set(bluetoothDeviceService.deviceSettings)

                    connectedDevice.get()?.synapseValues?.temperature?.let { temperature ->
                        convertedTemperature.set(
                            bluetoothDeviceService.deviceSettings.temperatureScale.convertValue(temperature)!!
                        )
                    }
                    connectedDevice.notifyChange()
                }

        disposable +=
            bluetoothDeviceService.deviceConnectionSubject
                .subscribe {

                    if (it.status.state == StatusState.READING_DATA)
                        updateDeviceSettings(false)
                }


        bluetoothDeviceService.establishConnectionWithSavedDevice()
    }

    fun getConnectionSubject() = bluetoothDeviceService.deviceConnectionSubject

    fun onPairAccepted() = bluetoothDeviceService.associateWithDevice()

    fun updateDeviceSettings(isInBackground: Boolean) = bluetoothDeviceService.updateDeviceSettings(isInBackground)

    override fun onCleared() {
        disposable.clear()
        super.onCleared()
    }
}