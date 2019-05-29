package com.synapsewear.service

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import io.reactivex.Single
import io.reactivex.schedulers.Schedulers
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okio.Okio
import java.io.File
import java.util.concurrent.TimeUnit


class NetworkService {

    private val okHttpClient: OkHttpClient

    init {
        val builder = OkHttpClient.Builder()
        builder.connectTimeout(20, TimeUnit.SECONDS)
        builder.readTimeout(20, TimeUnit.SECONDS)
        okHttpClient = builder.build()
    }

    fun createPostRequest(uploadURL: String, jsonClass: Any): Single<Response> {
        return Single.create<Response> {
            val requestBody = FormBody.Builder().add(
                "data",
                GsonBuilder().setPrettyPrinting().create().toJson(jsonClass)
            ).build()

            val requestBuilder = Request.Builder()
                .post(requestBody)
                .url(uploadURL)
                .build()

            val response = okHttpClient.newCall(requestBuilder).execute()

            if (!it.isDisposed && response.isSuccessful) {
                it.onSuccess(response)
            }

        }.subscribeOn(Schedulers.io())
    }

    fun <T : Any> createGetRequest(getURL: String, cls: Class<T>): Single<T> {
        return Single.create<T> {
            val requestBuilder = Request.Builder()
                .get()
                .url(getURL)
                .build()

            val response = okHttpClient.newCall(requestBuilder).execute()

            if (!it.isDisposed && response.isSuccessful) {
                val responseObject = Gson().fromJson(response.body()?.charStream(), cls)
                it.onSuccess(responseObject)
            }
        }
            .subscribeOn(Schedulers.io())
    }

    fun downloadFile(downloadURL: String, outFile: File): Single<File> {
        return Single.create<File> {
            val request = Request.Builder()
                .url(downloadURL)
                .build()

            val response = okHttpClient.newCall(request).execute()

            if (response.isSuccessful) {
                val source = Okio.buffer(response.body()!!.source())
                val sink = Okio.buffer(Okio.sink(outFile))
                source.readAll(sink)
                source.close()
                sink.close()
                if (!it.isDisposed) {
                    it.onSuccess(outFile)
                }
            }
        }.subscribeOn(Schedulers.io())
    }
}
