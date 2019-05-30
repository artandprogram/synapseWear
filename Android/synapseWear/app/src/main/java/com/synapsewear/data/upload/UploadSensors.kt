package com.synapsewear.data.upload

import com.google.gson.annotations.SerializedName
import com.synapsewear.utils.Utils

class UploadSensors(
    @SerializedName("voltage")
    var voltage: Float? = null,

    @SerializedName("CO2")
    var CO2: Int? = null,

    @SerializedName("airpressure")
    var airPressure: Float? = null,

    @SerializedName("illumination")
    var light: Int? = null,

    @SerializedName("humidity")
    var humidity: Int? = null,

    @SerializedName("date")
    var date: String,

    @SerializedName("temperature")
    var temperature: Float? = null,

    @SerializedName("envsound")
    var environmentalSound: Int? = null,

    @SerializedName("dateunix")
    var dateUnix: Long
) {

    companion object {
        fun fromFloatArray(array: Array<Float?>, date: Long) = UploadSensors(
            voltage = array[0],
            CO2 = array[1]?.toInt(),
            airPressure = array[2],
            light = array[3]?.toInt(),
            humidity = array[4]?.toInt(),
            temperature = array[5],
            environmentalSound = array[6]?.toInt(),
            dateUnix = date,
            date = Utils.formatDateWithTimezone(date)
        )

    }
}