package com.synapsewear.data.enums

class FirmwareUpdateStatus(
    var percentComplete: Int
) {
    companion object {
        const val ERROR = -2
        const val DOWNLOADING_UPDATE_FILE = -1
        const val COMPLETED = 100
    }
}