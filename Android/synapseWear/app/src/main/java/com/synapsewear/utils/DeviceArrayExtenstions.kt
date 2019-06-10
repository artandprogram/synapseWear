package com.synapsewear.utils

import java.nio.ByteBuffer

fun Boolean.toSynapseByte(): Byte {
    return if (this) {
        0x01
    } else {
        0x00
    }
}

fun ByteArray.toSynapseInt(range: IntRange, isUnsigned: Boolean): Int? {
    if (range.count() < 2 || this.size < range.elementAt(1)) return null

    return if (isUnsigned)
        ((this[range.elementAt(0)].toCustomUInt() shl 8) or (this[range.elementAt(1)].toCustomUInt()))
    else
        ((this[range.elementAt(0)].toInt() shl 8) or (this[range.elementAt(1)].toInt()))
}

fun ByteArray.toDate(range: IntRange): Int? {

    return if (range.count() == 4) {
        ByteBuffer.wrap(this.sliceArray(range)).int
    } else {
        null
    }
}

fun ByteArray.toSynapseFloat(range: IntRange): Float? {

    val arrayToParse: List<Float> = when {
        this.size < (range.last + 1) -> return null
        this[range.first] == 0xFF.toByte() || this[range.last] == 0xFF.toByte() -> return null
        else -> this.slice(range).map { it.toCustomUFloat() }
    }

    return when (arrayToParse.size) {
        2 -> arrayToParse[1] / 256f + arrayToParse[0]
        3 -> arrayToParse[0] * 256f + arrayToParse[1] + arrayToParse[2] * 0.01f
        else -> null
    }
}

fun ByteArray.batteryVoltageFromArray(firstIndex: Int, secondIndex: Int): Int? {
    if (this.size < secondIndex + 1) return null

    return (this[firstIndex].toCustomUInt() shl 4) or (this[secondIndex].toCustomUInt() shr 4)
}

fun Byte.toCustomUInt() =
    this.toInt() and 0xFF

fun Byte.toCustomUFloat() =
    this.toCustomUInt().toFloat()

fun ByteArray.contentToHexString(): String {
    var stringToReturn = "[ "
    this.forEach {
        stringToReturn = stringToReturn.plus("0x").plus((it.toHexString())).plus(" ")
    }
    stringToReturn = stringToReturn.plus("]")
    return stringToReturn
}

fun Byte.toHexString(): String {
    return Integer.toHexString(this.toCustomUInt())
}





