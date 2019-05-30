package com.synapsewear.service

import android.app.Application
import android.content.SharedPreferences
import android.preference.PreferenceManager
import android.util.Base64
import androidx.core.content.edit
import com.github.salomonbrys.kotson.fromJson
import com.google.gson.Gson
import com.synapsewear.data.settings.SynapseWearSettings

class SharedPreferencesRepository(application: Application) {

    var sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(application)

    fun saveDeviceMacAddress(macAddress: String) {
        sharedPreferences.edit {
            putString(SHARED_PREF_DEVICE_MAC_ADDRESS, macAddress)
        }
    }

    fun getSavedDeviceMacAddress(): String? {
        return sharedPreferences.getString(SHARED_PREF_DEVICE_MAC_ADDRESS, null)
    }

    private fun saveDeviceToken(deviceMacAddress: String, token: ByteArray) {
        val tokenString = Base64.encodeToString(token, Base64.DEFAULT)
        sharedPreferences.edit {
            putString(SHARED_PREF_DEVICE_TOKEN + deviceMacAddress, tokenString)
        }
    }

    fun saveDeviceToken(token: ByteArray) = saveDeviceToken(getSavedDeviceMacAddress()!!, token)

    fun getSavedDeviceToken(deviceMacAddress: String?): ByteArray? {
        if (deviceMacAddress == null) return null

        val savedTokenString = sharedPreferences.getString(SHARED_PREF_DEVICE_TOKEN + deviceMacAddress, null)
        return if (savedTokenString.isNullOrEmpty()) null else Base64.decode(savedTokenString, Base64.DEFAULT)
    }

    fun saveSettings(synapseWearSettings: SynapseWearSettings) {
        sharedPreferences.edit {
            putString(SHARED_PREF_DEVICE_SETTINGS, Gson().toJson(synapseWearSettings))
        }
    }

    fun getSettings() =
        sharedPreferences.getString(SHARED_PREF_DEVICE_SETTINGS, null)?.let {

            Gson().fromJson<SynapseWearSettings>(it)
        }


    companion object {
        const val SHARED_PREF_DEVICE_MAC_ADDRESS = "MAC_ADDRESS"
        const val SHARED_PREF_DEVICE_TOKEN = "TOKEN_FOR:"
        const val SHARED_PREF_DEVICE_SETTINGS = "DEVICE_SETTINGS"
    }
}