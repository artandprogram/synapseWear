package com.synapsewear.utils

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import com.polidea.rxandroidble2.RxBleClient
import com.synapsewear.R
import com.synapsewear.app.SynapseWearApplication
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.plusAssign
import timber.log.Timber

private const val REQUEST_CODE_ENABLE_BT = 999

fun Activity.observeBluetoothState(compositeDisposable: CompositeDisposable) {
    compositeDisposable +=
        SynapseWearApplication.rxBleClient.observeStateChanges()
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ state ->
                when (state) {
                    RxBleClient.State.BLUETOOTH_NOT_AVAILABLE -> {
                        Utils.showShortMessage(this, R.string.error_bluetooth_not_available)
                    }
                    RxBleClient.State.LOCATION_PERMISSION_NOT_GRANTED -> {
                        checkLocationPermission()
                    }
                    RxBleClient.State.LOCATION_SERVICES_NOT_ENABLED -> {
                        Utils.showShortMessage(this, R.string.error_location_services_disabled)
                    }
                    RxBleClient.State.BLUETOOTH_NOT_ENABLED -> {
                        initBluetooth()
                    }
                    else -> {
                        Timber.e("Bluetooth ready")
                    }
                }

            }, {
                Timber.e(it)
            })
}

fun Activity.checkLocationPermission() {
    if (!LocationPermission.isLocationPermissionGranted(this)) {
        LocationPermission.requestLocationPermission(this)
    }
}

fun Activity.initBluetooth() {
    val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
    startActivityForResult(enableBtIntent, REQUEST_CODE_ENABLE_BT)
}