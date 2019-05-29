package com.synapsewear.app.settings.base.fragment

import androidx.fragment.app.Fragment
import androidx.navigation.NavOptions
import androidx.navigation.Navigation
import com.synapsewear.R

abstract class BaseNavFragment : Fragment() {

    fun navigateWithAnimation(destinationRes: Int) {
        val navOptions = NavOptions.Builder()
            .setEnterAnim(R.anim.out_to_left)
            .setExitAnim(R.anim.in_from_right)
            .setPopEnterAnim(R.anim.in_from_left)
            .setPopExitAnim(R.anim.out_to_right)
            .build()

        Navigation.findNavController(view!!).navigate(destinationRes, null, navOptions)
    }
}