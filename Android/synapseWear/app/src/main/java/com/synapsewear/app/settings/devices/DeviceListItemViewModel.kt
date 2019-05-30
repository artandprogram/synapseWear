package com.synapsewear.app.settings.devices

import com.polidea.rxandroidble2.RxBleDevice
import com.synapsewear.app.settings.base.adapter.BaseSettingsListItemViewModel
import com.synapsewear.data.SettingsBaseListItem
import com.synapsewear.service.BluetoothDeviceService

class DeviceListItemViewModel(
    var rxBleDevice: RxBleDevice,
    private val bluetoothDeviceService: BluetoothDeviceService
) : BaseSettingsListItemViewModel(
    settingsBaseListItem = SettingsBaseListItem(
        title = rxBleDevice.macAddress
    ),
    onItemClick = {
        bluetoothDeviceService.establishConnectionWithDevice(rxBleDevice)
    },
    isItemSelected = { rxBleDevice.macAddress == bluetoothDeviceService.getConnectedDevice().macAddress })
