package com.synapsewear.app.settings.devices

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.synapsewear.app.settings.SettingsViewModel
import com.synapsewear.databinding.FragmentSettingsDetailsListBinding
import com.synapsewear.viewmodel.getViewModel
import io.reactivex.disposables.CompositeDisposable


class SettingsDevicesFragment : Fragment() {
    private val settingsViewModel by lazy {
        getViewModel<SettingsViewModel>()
    }

    private val scanDisposable = CompositeDisposable()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val settingsDetailsListBinding = FragmentSettingsDetailsListBinding.inflate(inflater, container, false)

        settingsDetailsListBinding.rvSettingDevices.adapter = settingsViewModel.devicesAdapter

        settingsViewModel.scanDevices(scanDisposable)

        return settingsDetailsListBinding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        scanDisposable.clear()
    }
}