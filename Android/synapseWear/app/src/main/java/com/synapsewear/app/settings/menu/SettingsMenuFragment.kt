package com.synapsewear.app.settings.menu

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.synapsewear.R
import com.synapsewear.app.settings.SettingsViewModel
import com.synapsewear.app.settings.base.fragment.BaseNavFragment
import com.synapsewear.databinding.FragmentSettingsMenuBinding
import com.synapsewear.viewmodel.getViewModel

class SettingsMenuFragment : BaseNavFragment() {

    private val settingsViewModel by lazy {
        getViewModel<SettingsViewModel>()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val settingMenuBinding = FragmentSettingsMenuBinding.inflate(inflater, container, false)

        settingMenuBinding.settingsViewModel = settingsViewModel

        initUIActions(settingMenuBinding)

        return settingMenuBinding.root
    }

    private fun initUIActions(settingsMenuBinding: FragmentSettingsMenuBinding) {
        settingsMenuBinding.layoutSettingsDevices.root.setOnClickListener {
            navigateWithAnimation(R.id.actionNavigateToSettingsDevices)
        }

        settingsMenuBinding.layoutSettingsInterval.root.setOnClickListener {
            navigateWithAnimation(R.id.actionNavigateToSettingsInterval)
        }

        settingsMenuBinding.layoutSettingsOsc.root.setOnClickListener {
            navigateWithAnimation(R.id.actionNavigateToSettingsOscFragment)
        }

        settingsMenuBinding.layoutSettingsUpload.root.setOnClickListener {
            navigateWithAnimation(R.id.actionNavigateToSettingsUploadFragment)
        }

        settingsMenuBinding.layoutSettingsFirmware.root.setOnClickListener {
            navigateWithAnimation(R.id.actionNavigateToSettingsFirmwareFragment)
        }
    }
}