package com.synapsewear.utils

import java.util.*

//DEVICE CONSTANTS

const val SYNAPSE_WEAR_SERVICE_UUID = "0000fdef-0000-1000-8000-00805f9b34fb"

val SYNAPSE_WEAR_DEFAULT_RECEIVE_UUID: UUID = UUID.fromString("2d30c082-f39f-4ce6-923f-3484ea480596")
val SYNAPSE_WEAR_DEFAULT_SEND_UUID: UUID = UUID.fromString("2d30c083-f39f-4ce6-923f-3484ea480596")
val SYNAPSE_WEAR_DEFAULT_DISCONNECT_UUID: UUID = UUID.fromString("2d30c084-f39f-4ce6-923f-3484ea480596")

const val BYTE_ARRAY_NO_HEADER_MAX_LENGTH = 20
const val DELAY_READ_WRITE_MIN = 200L
const val DELAY_STOP_SENDING_DATA_RESUME = 500L
const val DELAY_WRITE_FIRMWARE_LINE = 600L

val COMMAND_SAVE_TOKEN = byteArrayOf(0x00)

val VALUE_DEVICE_HEADER = byteArrayOf(0x00, 0xFF.toByte())
const val VALUE_RESPONSE_OK = 0x00.toByte()
val ARRAY_RESPONSE_ERROR = byteArrayOf(0x01)
val ARRAY_RESPONSE_OK = byteArrayOf(VALUE_RESPONSE_OK)

const val I1_COMMAND_START_SENDING_DATA = 0x02.toByte()
const val I2_COMMAND_STOP_SENDING_DATA = 0x03.toByte()
const val I3_COMMAND_CHANGE_INTERVAL_TIME = 0x04.toByte()
const val I4_COMMAND_CHANGE_SENSORS = 0x05.toByte()
val I5_COMMAND_CHECK_FIRMWARE_VERSION = byteArrayOf(0x06)
val I6_COMMAND_ASSOCIATE_WITH_DEVICE = byteArrayOf(0x10)
val I7_COMMAND_UPDATE_FIRMWARE = 0xFE.toByte()
val I8_COMMAND_FORCE_UPDATE_FIRMWARE = byteArrayOf(0x11)
val I9_COMMAND_RESET_ASSOCIATION = byteArrayOf(0x12, 0x01)
val I10_COMMAND_FLASH_LED = byteArrayOf(0x13)

val VALUE_SEND_INTERVAL_NORMAL = byteArrayOf(I3_COMMAND_CHANGE_INTERVAL_TIME, 0x00, 0x00, 0x00, 0x64, 0x00)
val VALUE_SEND_INTERVAL_NORMAL_BACKGROUND =
    byteArrayOf(I3_COMMAND_CHANGE_INTERVAL_TIME, 0x00, 0x00, 0xEA.toByte(), 0x60.toByte(), 0x00)
val VALUE_SEND_INTERVAL_LIVE = byteArrayOf(I3_COMMAND_CHANGE_INTERVAL_TIME, 0x00, 0x00, 0x00, 0x64, 0x01)
val VALUE_SEND_INTERVAL_LOW_POWER =
    byteArrayOf(I3_COMMAND_CHANGE_INTERVAL_TIME, 0x00, 0x04, 0x93.toByte(), 0xE0.toByte(), 0x02)

//OSC CONSTANTS

const val OSC_SEND_SYNAPSE_DATA_ROUTE = "/synapseWear"
const val OSC_SEND_SYNAPSE_KICK_ROUTE = "/synapseWearKick"
const val OSC_ACCELEROMETER_KICK_MIN_DIFF = 10000
const val OSC_CONNECTION_RETRY_TIMES_VALUE = 5L

//FIRMWARE CONSTANTS

const val FIRMWARE_BASE_URL = "https://firmware.synapsewear.com"
const val FIRMWARE_LIST_PATH = "$FIRMWARE_BASE_URL/list.php"