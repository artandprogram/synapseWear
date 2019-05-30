package com.synapsewear.data.firmware

import com.google.gson.annotations.SerializedName
import com.synapsewear.utils.toDate

class FirmwareVersion(
    @SerializedName("device_version")
    val versionMajor: Float,

    @SerializedName("date")
    val versionDate: Int?,

    @SerializedName("hex_file")
    val hexFileName: String? = null
) {
    companion object {
        fun fromByteArray(byteArray: ByteArray): FirmwareVersion? {
            return if (byteArray.size == 7)
                FirmwareVersion(
                    byteArray[1].toInt() + byteArray[2].toFloat() / 10,
                    byteArray.toDate(3..6)
                )
            else null
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as FirmwareVersion

        if (versionMajor != other.versionMajor) return false
        if (versionDate != other.versionDate) return false

        return true
    }

    override fun hashCode(): Int {
        var result = versionMajor.hashCode()
        result = 31 * result + (versionDate ?: 0)
        return result
    }


}