package com.synapsewear.utils

import android.content.Context
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.*


class Utils {
    companion object {
        fun formatDate(timestamp: Long): String {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())
            return dateFormat.format(Date(timestamp))
        }

        fun formatDateWithTimezone(timestamp: Long): String {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z", Locale.getDefault())
            return dateFormat.format(Date(timestamp))
        }

        fun showShortMessage(context: Context?, messageResource: Int) {
            Toast.makeText(context, messageResource, Toast.LENGTH_SHORT).show()
        }
    }
}

