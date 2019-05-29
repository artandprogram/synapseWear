package com.synapsewear.data.upload

import com.google.gson.annotations.SerializedName

class UploadData(
    @SerializedName("mac_address")
    val macAddress: String,

    @SerializedName("data")
    val uploadSensorArray: ArrayList<UploadSensors> = ArrayList()
)