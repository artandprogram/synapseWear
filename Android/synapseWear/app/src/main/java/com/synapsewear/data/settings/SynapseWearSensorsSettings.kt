package com.synapsewear.data.settings

import com.synapsewear.utils.toSynapseByte

data class SynapseWearSensorsSettings(

    var co2Sensor: Boolean = true,

    var temperatureSensor: Boolean = true,

    var humiditySensor: Boolean = true,

    var illuminationSensor: Boolean = true,

    var pressureSensor: Boolean = true,

    var soundSensor: Boolean = true,

    var movementSensor: Boolean = true,

    var angleSensor: Boolean = true,

    var ledSensor: Boolean = true

) {
    fun toByteArray() = byteArrayOf(
        0x00,
        co2Sensor.toSynapseByte(),
        temperatureSensor.toSynapseByte(),
        humiditySensor.toSynapseByte(),
        illuminationSensor.toSynapseByte(),
        pressureSensor.toSynapseByte(),
        soundSensor.toSynapseByte(),
        movementSensor.toSynapseByte(),
        angleSensor.toSynapseByte(),
        ledSensor.toSynapseByte()
    )
}