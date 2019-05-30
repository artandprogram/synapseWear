package com.synapsewear.app.settings.base.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.synapsewear.databinding.ListItemSettingsDetailsBinding

abstract class BaseSettingListAdapter : RecyclerView.Adapter<BaseSettingsListViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseSettingsListViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItemDeviceBinding =
            ListItemSettingsDetailsBinding.inflate(
                layoutInflater,
                parent,
                false
            )
        return BaseSettingsListViewHolder(listItemDeviceBinding)
    }
}