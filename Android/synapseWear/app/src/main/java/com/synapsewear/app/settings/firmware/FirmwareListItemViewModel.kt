package com.synapsewear.app.settings.firmware

import com.synapsewear.R
import com.synapsewear.app.settings.base.adapter.BaseSettingsListItemViewModel
import com.synapsewear.data.SettingsBaseListItem
import com.synapsewear.data.firmware.FirmwareVersion
import com.synapsewear.service.BluetoothDeviceService

class FirmwareListItemViewModel(
    var firmwareVersion: FirmwareVersion,
    private val bluetoothDeviceService: BluetoothDeviceService

) : BaseSettingsListItemViewModel(
    settingsBaseListItem = SettingsBaseListItem(
        title = firmwareVersion.versionMajor.toString() + "  " + firmwareVersion.versionDate.toString(),
        subtitle = R.string.device_version
    ),
    onItemClick = {
        bluetoothDeviceService.startFirmwareUpdate(firmwareVersion)
    },
    isItemSelected = { bluetoothDeviceService.getConnectedDevice().firmwareVersion == firmwareVersion })
