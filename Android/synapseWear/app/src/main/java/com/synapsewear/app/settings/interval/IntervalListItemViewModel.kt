package com.synapsewear.app.settings.interval

import com.synapsewear.app.settings.base.adapter.BaseSettingsListItemViewModel
import com.synapsewear.data.SettingsBaseListItem
import com.synapsewear.data.enums.Interval
import com.synapsewear.data.settings.SynapseWearSettings

class IntervalListItemViewModel(
    private var interval: Interval,
    private val deviceSettings: SynapseWearSettings,
    private var onDataSetChanged: () -> Unit

) : BaseSettingsListItemViewModel(
    settingsBaseListItem = SettingsBaseListItem(
        subtitle = interval.getResource()
    ),
    onItemClick = {
        deviceSettings.intervalTime = interval
        onDataSetChanged()
    },
    isItemSelected = { interval.interval == deviceSettings.intervalTime.interval })
