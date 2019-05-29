package com.synapsewear.app.settings.firmware

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.synapsewear.app.SynapseWearApplication
import com.synapsewear.app.settings.firmware.dialog.FirmwareUpdateDialog
import com.synapsewear.data.enums.FirmwareUpdateStatus
import com.synapsewear.databinding.FragmentSettingsDetailsListBinding
import com.synapsewear.service.BluetoothDeviceService
import com.synapsewear.viewmodel.getViewModel
import io.reactivex.disposables.CompositeDisposable
import java.io.File
import java.util.*


class SettingsFirmwareFragment : Fragment() {

    private val firmwareViewModel by lazy {
        getViewModel {
            FirmwareViewModel(
                BluetoothDeviceService.instance,
                SynapseWearApplication.networkService
            )
        }
    }

    private val firmwareDisposable = CompositeDisposable()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val settingsDetailsListBinding = FragmentSettingsDetailsListBinding.inflate(inflater, container, false)

        settingsDetailsListBinding.baseLoadingViewModel = firmwareViewModel

        initRecyclerView(settingsDetailsListBinding)
        initFirmwareStatusSubject()

        firmwareViewModel.getFirmwareVersions(firmwareDisposable)

        return settingsDetailsListBinding.root
    }

    private fun initRecyclerView(settingsDetailsListBinding: FragmentSettingsDetailsListBinding) {
        settingsDetailsListBinding.rvSettingDevices.adapter = firmwareViewModel.firmwareListAdapter
    }

    private fun initFirmwareStatusSubject() {
        firmwareViewModel.getFirmwareUpdateSubject().subscribe { firmwareStatus ->
            if (firmwareStatus.percentComplete == FirmwareUpdateStatus.DOWNLOADING_UPDATE_FILE) {

                val firmwareUpdateDialog = FirmwareUpdateDialog()
                firmwareUpdateDialog.show(fragmentManager, FirmwareUpdateDialog::class.java.simpleName)

                val file = File.createTempFile("firmware-" + Date().time, ".hex", context?.cacheDir)
                firmwareViewModel.downloadUpdateFile(firmwareDisposable, file)

            } else if (firmwareStatus.percentComplete == FirmwareUpdateStatus.COMPLETED) {
                activity?.finish()
            }
        }?.let { firmwareDisposable.add(it) }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        firmwareDisposable.clear()
    }
}