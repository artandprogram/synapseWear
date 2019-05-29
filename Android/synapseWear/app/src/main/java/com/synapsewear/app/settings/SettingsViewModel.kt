package com.synapsewear.app.settings

import android.os.ParcelUuid
import androidx.databinding.ObservableField
import androidx.lifecycle.ViewModel
import com.polidea.rxandroidble2.RxBleClient
import com.polidea.rxandroidble2.scan.ScanFilter
import com.polidea.rxandroidble2.scan.ScanSettings
import com.synapsewear.app.settings.devices.DevicesAdapter
import com.synapsewear.app.settings.interval.IntervalListAdapter
import com.synapsewear.data.settings.SynapseWearSettings
import com.synapsewear.service.BluetoothDeviceService
import com.synapsewear.service.SharedPreferencesRepository
import com.synapsewear.utils.SYNAPSE_WEAR_SERVICE_UUID
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import timber.log.Timber


class SettingsViewModel(
    private val rxBleClient: RxBleClient,
    private val bluetoothDeviceService: BluetoothDeviceService,
    private val sharedPreferencesRepository: SharedPreferencesRepository
) : ViewModel() {

    val deviceSettings = ObservableField<SynapseWearSettings>(bluetoothDeviceService.deviceSettings.copy())

    val devicesAdapter = DevicesAdapter()
    val intervalListAdapter = IntervalListAdapter(deviceSettings.get())

    init {
        bluetoothDeviceService.getConnectedRxBleDevice()?.let { devicesAdapter.addScanResult(it) }
    }

    val deviceConnectionSubject = bluetoothDeviceService.deviceConnectionSubject

    fun scanDevices(disposable: CompositeDisposable) {

        val scanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES)
            .build()

        val scanFilter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid.fromString(SYNAPSE_WEAR_SERVICE_UUID))
            .build()

        disposable.add(rxBleClient.scanBleDevices(scanSettings, scanFilter)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { rxBleScanResult ->
                    devicesAdapter.addScanResult(rxBleScanResult.bleDevice)
                },
                { throwable ->
                    Timber.e(throwable)
                }
            )
        )
    }

    fun updateSensorSettings() {
        sharedPreferencesRepository.saveSettings(deviceSettings.get()!!)
    }

    fun toggleTemperatureScale() {
        deviceSettings.get()?.temperatureScale?.toggleValue()
        deviceSettings.notifyChange()
    }

    fun getTargetDevice() = bluetoothDeviceService.getConnectedDevice()
}
