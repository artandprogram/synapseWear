package com.synapsewear.data.device

import com.synapsewear.utils.batteryVoltageFromArray
import com.synapsewear.utils.toSynapseFloat
import com.synapsewear.utils.toSynapseInt
import java.util.*

class SynapseValues(
    var time: Long? = null,

    var CO2: Int? = null,

    var accelerometerX: Int? = null,

    var accelerometerY: Int? = null,

    var accelerometerZ: Int? = null,

    var gyroscopeX: Int? = null,

    var gyroscopeY: Int? = null,

    var gyroscopeZ: Int? = null,

    var light: Int? = null,

    var temperature: Float? = null,

    var humidity: Int? = null,

    var airPressure: Float? = null,

    var environmentalSound: Int? = null,

    var remainingBattery: Float? = null,

    var tVOC: Int? = null,

    var voltage: Float? = null
) {
    companion object {
        private const val ACCELEROMETER_SCALE: Float = 2f / 32768f

        private const val GYROSCOPE_SCALE: Float = 250f / 32768f * (Math.PI / 180.0).toFloat()

        private const val VOLTAGE_SCALE = 0.00125f

        fun fromByteArray(byteArray: ByteArray): SynapseValues? {
            return if (byteArray[3].toInt() == 0x02) {
                SynapseValues(
                    time = Date().time,

                    CO2 = byteArray.toSynapseInt(4..5, true),

                    accelerometerX = byteArray.toSynapseInt(6..7, false),
                    accelerometerY = byteArray.toSynapseInt(8..9, false),
                    accelerometerZ = byteArray.toSynapseInt(10..11, false),

                    gyroscopeX = byteArray.toSynapseInt(12..13, false),
                    gyroscopeY = byteArray.toSynapseInt(14..15, false),
                    gyroscopeZ = byteArray.toSynapseInt(16..17, false),

                    light = byteArray.toSynapseInt(18..19, true),

                    temperature = byteArray.toSynapseFloat(20..21),
                    humidity = byteArray[22].toInt(),

                    airPressure = byteArray.toSynapseFloat(23..25),

                    tVOC = byteArray.toSynapseInt(26..27, true),
                    voltage = byteArray.batteryVoltageFromArray(28, 29)?.times(VOLTAGE_SCALE),
                    remainingBattery = byteArray.toSynapseFloat(30..31),
                    environmentalSound = byteArray.toSynapseInt(32..33, true)
                )
            } else return null
        }
    }

    fun getAccelerometerArray() =
        arrayListOf(
            accelerometerX?.times(ACCELEROMETER_SCALE)?.unaryMinus() ?: 0f,
            accelerometerY?.times(ACCELEROMETER_SCALE)?.unaryMinus() ?: 0f,
            accelerometerZ?.times(ACCELEROMETER_SCALE) ?: 0f
        )

    fun getGyroscopeArray() =
        arrayListOf(
            gyroscopeX?.times(GYROSCOPE_SCALE)?.unaryMinus() ?: 0f,
            gyroscopeY?.times(GYROSCOPE_SCALE)?.unaryMinus() ?: 0f,
            gyroscopeY?.times(GYROSCOPE_SCALE) ?: 0f
        )

    fun getSynapseArray() = arrayListOf(

        time.toString(),
        CO2 ?: 0,
        accelerometerX ?: 0,

        accelerometerY ?: 0,
        accelerometerZ ?: 0,

        light ?: 0,

        gyroscopeX ?: 0,
        gyroscopeY ?: 0,
        gyroscopeZ ?: 0,

        airPressure ?: 0,
        temperature ?: 0,
        humidity ?: 0,
        environmentalSound ?: 0,
        tVOC ?: 0,
        voltage ?: 0,
        remainingBattery ?: 0
    )

    fun getSynapseBaseArray() = arrayListOf(
        voltage,
        CO2?.toFloat(),
        airPressure,
        light?.toFloat(),
        humidity?.toFloat(),
        temperature,
        environmentalSound?.toFloat()
    )

}
