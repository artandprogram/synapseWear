package com.synapsewear.data.enums

import com.synapsewear.R

class TemperatureScale(
    var scale: Int
) {
    fun getResource(): Int {
        return if (scale == CELSIUS)
            R.string.celsius_label
        else R.string.fahrenheit_label
    }

    fun convertValue(temperature: Float?): Float? {
        return when {
            temperature == null -> null
            scale == CELSIUS -> temperature
            else -> (temperature * 1.8f) + 32f
        }
    }

    fun toggleValue() {
        scale = if (scale == CELSIUS)
            FAHRENHEIT
        else CELSIUS
    }

    companion object {
        const val CELSIUS = 0
        const val FAHRENHEIT = 1
    }
}