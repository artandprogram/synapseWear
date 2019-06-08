package com.synapsewear.service


import com.synapsewear.data.device.SynapseValues
import com.synapsewear.data.settings.UploadSettings
import com.synapsewear.data.upload.UploadData
import com.synapsewear.data.upload.UploadSensors
import io.reactivex.Completable
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.addTo
import io.reactivex.schedulers.Schedulers
import timber.log.Timber
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
            Single.just {
                createAverageValuesArray(dateLastAdded!!.time)
            }.subscribe({
                if (calendarLastAdded.get(Calendar.MINUTE) != calendarNow.get(Calendar.MINUTE)
                    && uploadSettings.uploadEnabled) {
                    sendData()
                }
                dateLastAdded = dateNow
            },{
                Timber.e(it)
            })
                .let { disposable.add(it) }
        }
    }

    private fun sendData(){
        networkService
            .createPostRequest(uploadSettings.uploadURL, uploadData)
            .subscribe({
                uploadData.uploadSensorArray.clear()
            },{
                Timber.e(it)
            }).addTo(disposable)
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