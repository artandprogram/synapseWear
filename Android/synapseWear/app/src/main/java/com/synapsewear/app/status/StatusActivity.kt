package com.synapsewear.app.status

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.synapsewear.R
import com.synapsewear.app.settings.SettingsActivity
import com.synapsewear.data.enums.StatusState
import com.synapsewear.databinding.ActivityStatusBinding
import com.synapsewear.service.BluetoothDeviceService
import com.synapsewear.utils.checkLocationPermission
import com.synapsewear.utils.initBluetooth
import com.synapsewear.utils.observeBluetoothState
import com.synapsewear.viewmodel.getViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable


class StatusActivity : AppCompatActivity() {

    private val statusViewModel by lazy {
        getViewModel {
            StatusViewModel(
                BluetoothDeviceService.instance
            )
        }
    }

    private val connectionDisposable = CompositeDisposable()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val statusBinding =
            DataBindingUtil.setContentView<ActivityStatusBinding>(this, R.layout.activity_status)

        checkLocationPermission()
        initViewModel(statusBinding)
        initUIActions(statusBinding)
        initBluetooth()
        initConnectionSubject()
        observeBluetoothState(connectionDisposable)
    }


    private fun initViewModel(statusBinding: ActivityStatusBinding) {
        statusBinding.statusViewModel = statusViewModel
    }


    private fun initUIActions(statusBinding: ActivityStatusBinding) {
        statusBinding.layoutToolbarStatus.ivToolbarBaseEnd.setOnClickListener {
            val intent = Intent(this, SettingsActivity::class.java)
            startActivity(intent)
        }
    }

    private fun initConnectionSubject() {
        connectionDisposable.add(
            statusViewModel.getConnectionSubject()
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    statusViewModel.connectedDevice.set(it)
                    if (it.status.state == StatusState.PAIRING) {
                        val builder = AlertDialog.Builder(this)
                            .setMessage(getString(R.string.alert_pair_placeholder, it.macAddress))
                            .setPositiveButton(R.string.yes) { _, _ -> statusViewModel.onPairAccepted() }
                            .setNegativeButton(R.string.no, null)
                        val alert = builder.create()
                        alert.show()
                    }
                }
        )
    }

    override fun onDestroy() {
        connectionDisposable.clear()
        super.onDestroy()
    }

    override fun onStart() {
        super.onStart()
        statusViewModel.updateDeviceSettings(false)
    }
}
