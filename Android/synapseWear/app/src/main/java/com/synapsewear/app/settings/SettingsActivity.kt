package com.synapsewear.app.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.navigation.Navigation
import com.synapsewear.R
import com.synapsewear.app.SynapseWearApplication
import com.synapsewear.app.settings.devices.SettingsDevicesFragment
import com.synapsewear.app.settings.firmware.SettingsFirmwareFragment
import com.synapsewear.app.settings.interval.SettingsIntervalFragment
import com.synapsewear.app.settings.menu.SettingsMenuFragment
import com.synapsewear.app.settings.osc.SettingsOscFragment
import com.synapsewear.app.settings.upload.SettingsUploadFragment
import com.synapsewear.data.enums.StatusState
import com.synapsewear.databinding.ActivitySettingsBinding
import com.synapsewear.databinding.ToolbarBaseBinding
import com.synapsewear.service.BluetoothDeviceService
import com.synapsewear.viewmodel.getViewModel
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.plusAssign

class SettingsActivity : AppCompatActivity() {

    private val devicesViewModel by lazy {
        getViewModel {
            SettingsViewModel(
                SynapseWearApplication.rxBleClient,
                BluetoothDeviceService.instance,
                SynapseWearApplication.sharedPreferencesRepository
            )
        }
    }

    private val connectionDisposable = CompositeDisposable()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val settingsBinding =
            DataBindingUtil.setContentView<ActivitySettingsBinding>(this, R.layout.activity_settings)

        initUIActions(settingsBinding)
        initNavigation(settingsBinding.layoutToolbarSettings)
        initConnectionCallback()
    }

    private fun initUIActions(settingsBinding: ActivitySettingsBinding) {
        settingsBinding.layoutToolbarSettings.ivToolbarBaseEnd.setOnClickListener {
            onBackPressed()
        }
    }

    private fun initNavigation(layoutToolbarBaseBinding: ToolbarBaseBinding) {
        Navigation.findNavController(this, R.id.nav_host_fragment)
            .addOnDestinationChangedListener { _, destination, _ ->

                var toolbarDrawable: Int? = null

                val toolbarTitle = when (destination.label) {
                    SettingsMenuFragment::class.java.simpleName -> {
                        toolbarDrawable = R.drawable.ic_cancel
                        R.string.settings
                    }
                    SettingsDevicesFragment::class.java.simpleName -> {
                        R.string.device_fragment_toolbar_title
                    }
                    SettingsIntervalFragment::class.java.simpleName -> {
                        R.string.interval_time
                    }
                    SettingsOscFragment::class.java.simpleName -> {
                        R.string.osc_settings
                    }
                    SettingsUploadFragment::class.java.simpleName -> {
                        R.string.upload_settings
                    }
                    SettingsFirmwareFragment::class.java.simpleName -> {
                        R.string.firmware_update
                    }
                    else -> throw IllegalArgumentException("The ${destination.label} is not supported.")
                }

                layoutToolbarBaseBinding.title = getString(toolbarTitle)
                layoutToolbarBaseBinding.drawableEnd =
                    if (toolbarDrawable != null) getDrawable(toolbarDrawable) else null
            }
    }

    private fun initConnectionCallback() {
        connectionDisposable +=
            devicesViewModel.deviceConnectionSubject.subscribe {
                if (it.status.state == StatusState.CONNECTING)
                    finish()
            }
    }

    override fun onPause() {
        devicesViewModel.updateSensorSettings()
        super.onPause()
    }

    override fun onDestroy() {
        connectionDisposable.clear()
        super.onDestroy()
    }
}