package com.synapsewear.service

import com.illposed.osc.OSCMessage
import com.illposed.osc.OSCPortOut
import com.synapsewear.data.device.SynapseValues
import com.synapsewear.data.settings.OscSettings
import com.synapsewear.utils.OSC_ACCELEROMETER_KICK_MIN_DIFF
import com.synapsewear.utils.OSC_CONNECTION_RETRY_TIMES_VALUE
import com.synapsewear.utils.OSC_SEND_SYNAPSE_DATA_ROUTE
import com.synapsewear.utils.OSC_SEND_SYNAPSE_KICK_ROUTE
import io.reactivex.Completable
import io.reactivex.disposables.CompositeDisposable
import timber.log.Timber
import java.net.InetAddress
import kotlin.math.absoluteValue


class OscService {

    private var oscSettings: OscSettings? = null
    private var oscPortOut: OSCPortOut? = null

    private var disposable = CompositeDisposable()

    private var lastAccelerometerValue: Int? = null

    fun changeSettings(oscSettings: OscSettings) {
        if (this.oscSettings != oscSettings) {

            disposable.clear()
            this.oscSettings = oscSettings

            Completable.create {
                try {
                    oscPortOut = OSCPortOut(
                        InetAddress.getByName(oscSettings.oscIP),
                        oscSettings.oscPort.toInt()
                    )
                } catch (e: Exception) {
                    Timber.e(e)
                }
                it.onComplete()
            }.retry(OSC_CONNECTION_RETRY_TIMES_VALUE)
                .subscribe().let { disposable.add(it) }
        }
    }

    fun sendData(synapseValues: SynapseValues?) {
        if (synapseValues == null || oscSettings == null || !oscSettings!!.oscSendEnabled) return

        Completable.create {
            val synapseData = OSCMessage(OSC_SEND_SYNAPSE_DATA_ROUTE, synapseValues.getSynapseArray())

            val accelerometerKickData: OSCMessage? = getKickMessage(synapseValues)

            lastAccelerometerValue = synapseValues.accelerometerX

            try {
                oscPortOut?.send(synapseData)
                accelerometerKickData?.let { oscPortOut?.send(it) }
            } catch (e: Exception) {
                Timber.e(e)
            }
        }.subscribe()
            .let { disposable.add(it) }
    }

    private fun getKickMessage(synapseValues: SynapseValues): OSCMessage? =
        lastAccelerometerValue?.let {
            if (synapseValues.accelerometerX?.minus(it)?.absoluteValue?.compareTo(OSC_ACCELEROMETER_KICK_MIN_DIFF) == 1) {
                OSCMessage(OSC_SEND_SYNAPSE_KICK_ROUTE, listOf(synapseValues.time?.toFloat()))
            } else {
                null
            }
        }

}