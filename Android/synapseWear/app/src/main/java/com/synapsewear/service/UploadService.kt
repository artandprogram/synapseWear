package com.synapsewear.service


import com.synapsewear.data.device.SynapseValues
import com.synapsewear.data.settings.UploadSettings
import com.synapsewear.data.upload.UploadData
import com.synapsewear.data.upload.UploadSensors
import io.reactivex.Completable
import io.reactivex.disposables.CompositeDisposable
import java.util.*
import kotlin.collections.ArrayList


class UploadService(private val networkService: NetworkService) {

    private val disposable = CompositeDisposable()

    private var uploadSettings = UploadSettings()
    private lateinit var uploadData: UploadData

    private var dateLastAdded: Date? = null
    private var arrayToAdd = ArrayList<SynapseValues>()

    fun init(macAddress: String) {
        uploadData = UploadData(macAddress)
    }

    fun changeSettings(newSettings: UploadSettings) {
        uploadSettings = newSettings
    }

    fun addValue(synapseValues: SynapseValues?) {
        if (dateLastAdded == null) {
            dateLastAdded = Date()
        }
        if (synapseValues?.time == null)
            return

        val calendarLastAdded = Calendar.getInstance()
        val calendarNow = Calendar.getInstance()

        val dateNow = Date(synapseValues.time!!)

        calendarLastAdded.time = dateLastAdded
        calendarNow.time = dateNow

        if (calendarLastAdded.get(Calendar.MINUTE) == calendarNow.get(Calendar.MINUTE)) {
            arrayToAdd.add(synapseValues)
        } else {
            Completable.create {
                createAverageValuesArray(dateLastAdded!!.time)
                if (calendarLastAdded.get(Calendar.MINUTE) != calendarNow.get(Calendar.MINUTE) && uploadSettings.uploadEnabled) {
                    networkService.createPostRequest(uploadSettings.uploadURL, uploadData).subscribe()
                    uploadData.uploadSensorArray.clear()
                }
                dateLastAdded = dateNow

            }.subscribe().let { disposable.add(it) }
        }
    }

    private fun createAverageValuesArray(date: Long) {
        val sensorValues = Array<Float?>(7) { null }

        val calendarRound = Calendar.getInstance()
        calendarRound.time = Date(date)
        calendarRound.add(Calendar.SECOND, 60 - calendarRound.get(Calendar.SECOND))

        arrayToAdd.forEach { deviceToAdd ->
            deviceToAdd.getSynapseBaseArray().forEachIndexed { index, value ->
                value?.div(arrayToAdd.size)?.let { sensorValues[index] = sensorValues[index]?.plus(it) ?: it }
            }
        }
        arrayToAdd.clear()

        uploadData.uploadSensorArray.add(UploadSensors.fromFloatArray(sensorValues, date))
    }

}