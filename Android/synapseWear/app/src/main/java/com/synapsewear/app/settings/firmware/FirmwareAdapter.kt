package com.synapsewear.app.settings.firmware

import com.synapsewear.app.settings.base.adapter.BaseSettingListAdapter
import com.synapsewear.app.settings.base.adapter.BaseSettingsListViewHolder
import com.synapsewear.data.firmware.FirmwareVersion
import com.synapsewear.service.BluetoothDeviceService
import java.util.*

class FirmwareAdapter : BaseSettingListAdapter() {

    private var firmwareListItemViewModels = mutableListOf<FirmwareListItemViewModel>()

    override fun getItemCount(): Int = firmwareListItemViewModels.size

    override fun onBindViewHolder(holder: BaseSettingsListViewHolder, position: Int) {
        holder.bindTo(firmwareListItemViewModels[position])
    }

    fun addFirmwareVersions(firmwareArrayList: ArrayList<FirmwareVersion>) {

        firmwareArrayList.forEach {
            firmwareListItemViewModels.add(
                FirmwareListItemViewModel(
                    firmwareVersion = it,
                    bluetoothDeviceService = BluetoothDeviceService.instance
                )
            )
            notifyDataSetChanged()
        }
    }

    fun clearList() = firmwareListItemViewModels.clear()

}