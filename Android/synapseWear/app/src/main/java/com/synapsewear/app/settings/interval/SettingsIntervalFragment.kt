package com.synapsewear.app.settings.interval

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.synapsewear.app.settings.SettingsViewModel
import com.synapsewear.databinding.FragmentSettingsDetailsListBinding
import com.synapsewear.viewmodel.getViewModel


class SettingsIntervalFragment : Fragment() {
    private val settingsViewModel by lazy {
        getViewModel<SettingsViewModel>()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val settingsDetailsListBinding = FragmentSettingsDetailsListBinding.inflate(inflater, container, false)

        settingsDetailsListBinding.rvSettingDevices.adapter = settingsViewModel.intervalListAdapter

        return settingsDetailsListBinding.root
    }

}