package com.synapsewear.app.settings.firmware.dialog

import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.Window
import androidx.appcompat.app.AppCompatDialogFragment
import com.synapsewear.R
import com.synapsewear.app.settings.firmware.FirmwareViewModel
import com.synapsewear.data.enums.FirmwareUpdateStatus
import com.synapsewear.databinding.DialogUpdateFirmwareBinding
import com.synapsewear.viewmodel.getViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable

class FirmwareUpdateDialog : AppCompatDialogFragment() {
    private val firmwareViewModel by lazy {
        getViewModel<FirmwareViewModel>()
    }

    private val compositeDisposable = CompositeDisposable()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        isCancelable = false

        val builder = AlertDialog.Builder(activity)
        val dialogUpdateFirmwareBinding = DialogUpdateFirmwareBinding.inflate(LayoutInflater.from(context))

        builder.setView(dialogUpdateFirmwareBinding.root)
        val dialog = builder.create()
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)

        initViewModel(dialogUpdateFirmwareBinding)
        initListeners(dialogUpdateFirmwareBinding)
        return dialog
    }

    private fun initViewModel(dialogUpdateFirmwareBinding: DialogUpdateFirmwareBinding) {
        firmwareViewModel.getFirmwareUpdateSubject()
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { status ->
                if (status.percentComplete != FirmwareUpdateStatus.DOWNLOADING_UPDATE_FILE) {
                    dialogUpdateFirmwareBinding.tvUpdateFirmwareStatus.setText(R.string.installing_firmware_update)
                    dialogUpdateFirmwareBinding.pbUpdateFirmware.progress = status.percentComplete
                } else if (status.percentComplete == FirmwareUpdateStatus.ERROR) {
                    dismiss()
                }
            }
            ?.let { compositeDisposable.add(it) }
    }

    private fun initListeners(dialogUpdateFirmwareBinding: DialogUpdateFirmwareBinding) {
        dialogUpdateFirmwareBinding.tvDialogCancel.setOnClickListener {
            dismiss()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        compositeDisposable.clear()
    }
}