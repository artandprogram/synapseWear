package com.synapsewear.app.settings.interval

import com.synapsewear.app.settings.base.adapter.BaseSettingListAdapter
import com.synapsewear.app.settings.base.adapter.BaseSettingsListViewHolder
import com.synapsewear.data.enums.Interval
import com.synapsewear.data.settings.SynapseWearSettings

class IntervalListAdapter(private val synapseWearSettings: SynapseWearSettings?) : BaseSettingListAdapter() {

    private var intervalListItemViewModels = mutableListOf<IntervalListItemViewModel>()

    init {
        Interval.getValues().forEach { interval ->
            intervalListItemViewModels.add(
                IntervalListItemViewModel(
                    interval,
                    synapseWearSettings ?: SynapseWearSettings()
                ) {
                    notifyDataSetChanged()
                }
            )
            notifyItemInserted(itemCount - 1)
        }
    }

    override fun getItemCount(): Int = intervalListItemViewModels.size

    override fun onBindViewHolder(holder: BaseSettingsListViewHolder, position: Int) {
        holder.bindTo(intervalListItemViewModels[position])

    }
}