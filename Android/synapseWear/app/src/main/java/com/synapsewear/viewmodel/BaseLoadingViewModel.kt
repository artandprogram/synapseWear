package com.synapsewear.viewmodel

import androidx.databinding.ObservableBoolean
import androidx.lifecycle.ViewModel

abstract class BaseLoadingViewModel : ViewModel() {

    val isLoading = ObservableBoolean(true)
}