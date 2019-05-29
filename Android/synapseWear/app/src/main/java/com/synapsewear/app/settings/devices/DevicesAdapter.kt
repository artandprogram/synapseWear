package com.synapsewear.app.settings.devices

import com.polidea.rxandroidble2.RxBleDevice
import com.synapsewear.app.settings.base.adapter.BaseSettingListAdapter
import com.synapsewear.app.settings.base.adapter.BaseSettingsListViewHolder
import com.synapsewear.service.BluetoothDeviceService

class DevicesAdapter : BaseSettingListAdapter() {

    private var devicesListItemViewModels = mutableListOf<DeviceListItemViewModel>()

    override fun getItemCount(): Int = devicesListItemViewModels.size

    override fun onBindViewHolder(holder: BaseSettingsListViewHolder, position: Int) {
        holder.bindTo(devicesListItemViewModels[position])
    }

    fun addScanResult(rxBleDevice: RxBleDevice) {

        val deviceListItemViewModel = devicesListItemViewModels
            .firstOrNull { it.rxBleDevice.macAddress == rxBleDevice.macAddress }

        deviceListItemViewModel ?: let {
            devicesListItemViewModels.add(
                DeviceListItemViewModel(
                    rxBleDevice,
                    BluetoothDeviceService.instance
                )
            )
            notifyItemInserted(itemCount - 1)
        }
    }

}