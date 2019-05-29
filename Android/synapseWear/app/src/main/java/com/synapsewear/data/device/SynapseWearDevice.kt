package com.synapsewear.data.device

import com.synapsewear.data.enums.StatusState
import com.synapsewear.data.firmware.FirmwareVersion

data class SynapseWearDevice(
    val macAddress: String?,

    var status: StatusState = StatusState(),

    var firmwareVersion: FirmwareVersion? = null,

    var synapseValues: SynapseValues? = null

)
