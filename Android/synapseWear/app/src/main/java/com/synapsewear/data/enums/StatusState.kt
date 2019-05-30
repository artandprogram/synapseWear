package com.synapsewear.data.enums

import com.synapsewear.R

data class StatusState(

    val state: Int = NOT_ASSOCIATED
) {
    fun getStatusResource(): Int {
        return if (state == NOT_ASSOCIATED)
            R.string.not_associated
        else R.string.associated
    }

    companion object {
        const val CONNECTING = 0
        const val NOT_ASSOCIATED = 1
        const val ASSOCIATED = 2
        const val PAIRING = 3
        const val READING_DATA = 4
    }
}