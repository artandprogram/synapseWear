package com.synapsewear.utils

import android.view.View
import android.widget.TextView
import androidx.databinding.BindingAdapter
import com.synapsewear.R


@BindingAdapter("android:visibility")
fun View.setVisible(isVisible: Boolean) {
    visibility = if (isVisible) View.VISIBLE else View.GONE
}

@BindingAdapter("android:text")
fun TextView.setText(textResource: Int?) {
    if (textResource != null) {
        setText(textResource)
    }
}

@BindingAdapter("synapseValue")
fun TextView.setSynapseValue(value: Any?) {
    text = when (value) {
        is Float -> {
            context.getString(R.string.float_placeholder, value)
        }
        is Int -> {
            value.toString()
        }
        is String -> {
            value
        }
        is ArrayList<*> -> {
            var nonZeroValueExists = false
            value.forEach { element ->
                if (element != 0f) nonZeroValueExists = true
            }
            if (value.size == 3 && nonZeroValueExists) {
                context.getString(
                    R.string.move_placeholder,
                    value[0] as Float, value[1] as Float, value[2] as Float
                )
            } else {
                ""
            }
        }
        is Long -> {
            Utils.formatDate(value)
        }
        else -> ""
    }
}