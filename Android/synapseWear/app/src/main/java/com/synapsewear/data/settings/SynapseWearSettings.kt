package com.synapsewear.data.settings

import com.synapsewear.data.enums.Interval
import com.synapsewear.data.enums.Interval.Companion.NORMAL
import com.synapsewear.data.enums.TemperatureScale
import com.synapsewear.data.enums.TemperatureScale.Companion.CELSIUS

data class SynapseWearSettings(

    var temperatureScale: TemperatureScale = TemperatureScale(CELSIUS),

    var firmwareUrl: String = "",

    var intervalTime: Interval = Interval(NORMAL),

    val sensorsValues: SynapseWearSensorsSettings = SynapseWearSensorsSettings(),

    val oscSettings: OscSettings = OscSettings(),

    val uploadSettings: UploadSettings = UploadSettings()
)