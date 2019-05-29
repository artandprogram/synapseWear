package com.synapsewear.data.enums

import com.synapsewear.R
import com.synapsewear.utils.VALUE_SEND_INTERVAL_LIVE
import com.synapsewear.utils.VALUE_SEND_INTERVAL_LOW_POWER
import com.synapsewear.utils.VALUE_SEND_INTERVAL_NORMAL
import com.synapsewear.utils.VALUE_SEND_INTERVAL_NORMAL_BACKGROUND

class Interval(
    val interval: Int
) {
    companion object {
        const val NORMAL = 0
        const val LIVE = 1
        const val LOW_POWER = 2

        fun getValues() = arrayListOf(
            Interval(NORMAL),
            Interval(LIVE),
            Interval(LOW_POWER)
        )
    }

    fun getAppCommand(isBackground: Boolean): ByteArray =
        if (isBackground)
            if (interval == NORMAL) VALUE_SEND_INTERVAL_NORMAL_BACKGROUND
            else getAppCommand(false)
        else when (interval) {
            NORMAL -> VALUE_SEND_INTERVAL_NORMAL
            LIVE -> VALUE_SEND_INTERVAL_LIVE
            else -> VALUE_SEND_INTERVAL_LOW_POWER
        }


    fun getResource() =
        when (interval) {
            NORMAL -> R.string.normal
            LIVE -> R.string.live
            else -> R.string.low_power
        }

}