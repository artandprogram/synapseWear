package com.synapsewear.app

import android.app.Application
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import com.polidea.rxandroidble2.RxBleClient
import com.polidea.rxandroidble2.internal.RxBleLog
import com.synapsewear.BuildConfig
import com.synapsewear.service.*
import io.reactivex.plugins.RxJavaPlugins
import timber.log.Timber


class SynapseWearApplication : Application(), LifecycleObserver {

    override fun onCreate() {
        super.onCreate()

        if (BuildConfig.DEBUG) {
            RxBleClient.setLogLevel(RxBleLog.DEBUG)
            Timber.plant(Timber.DebugTree())
        }

        RxJavaPlugins.setErrorHandler { throwable -> Timber.e(throwable) }

        initDiComponents()

        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    private fun initDiComponents() {
        rxBleClient = RxBleClient.create(this)
        sharedPreferencesRepository = SharedPreferencesRepository(this)
        networkService = NetworkService()
        uploadService = UploadService(networkService)
        oscService = OscService()
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onAppBackgrounded() {
        BluetoothDeviceService.instance.updateDeviceSettings(true)
    }

    companion object {
        lateinit var rxBleClient: RxBleClient
            private set

        lateinit var sharedPreferencesRepository: SharedPreferencesRepository
            private set

        lateinit var networkService: NetworkService
            private set

        lateinit var uploadService: UploadService
            private set

        lateinit var oscService: OscService
            private set
    }


}