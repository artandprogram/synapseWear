package com.synapsewear.data.firmware

import com.google.gson.annotations.SerializedName

class FirmwareResponse(
    @SerializedName("firmware")
    val firmwareList: ArrayList<FirmwareVersion>
)