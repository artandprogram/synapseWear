package com.synapsewear.app.settings.osc

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.synapsewear.app.settings.SettingsViewModel
import com.synapsewear.databinding.FragmentSettingsOscBinding
import com.synapsewear.viewmodel.getViewModel

class SettingsOscFragment : Fragment() {
    private val settingsViewModel by lazy {
        getViewModel<SettingsViewModel>()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val settingsOscBinding = FragmentSettingsOscBinding.inflate(inflater, container, false)

        settingsOscBinding.settingsViewModel = settingsViewModel

        return settingsOscBinding.root
    }
}