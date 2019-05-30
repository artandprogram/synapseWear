package com.synapsewear.app.settings.base.adapter

import androidx.lifecycle.ViewModel
import com.synapsewear.data.SettingsBaseListItem

abstract class BaseSettingsListItemViewModel(
    var settingsBaseListItem: SettingsBaseListItem,
    var isItemSelected: () -> Boolean,
    var onItemClick: () -> Unit
) : ViewModel() {

    fun isSelected() =
        isItemSelected()


    fun onClick() =
        onItemClick()

}