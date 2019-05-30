package com.synapsewear.app.settings.base.adapter

import androidx.recyclerview.widget.RecyclerView
import com.synapsewear.databinding.ListItemSettingsDetailsBinding


class BaseSettingsListViewHolder(val binding: ListItemSettingsDetailsBinding) : RecyclerView.ViewHolder(binding.root) {

    fun bindTo(settingsListItemViewModel: BaseSettingsListItemViewModel) {
        binding.settingListItemViewModel = settingsListItemViewModel
        binding.executePendingBindings()
    }
}