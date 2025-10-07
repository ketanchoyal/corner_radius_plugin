package com.ketanchoyal.corner_radius_plugin

import android.content.Context
import android.app.Activity
import android.os.Build
import android.view.DisplayCutout
import android.view.WindowInsets
import android.view.WindowMetrics
import android.view.View
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CornerRadiusPlugin */
class CornerRadiusPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getScreenRadius" -> {
                val view = activity.window.decorView.rootView
                val radii = getScreenCornerRadii(view)
                result.success(radii)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "corner_radius_plugin")
        channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.applicationContext
    }

    override fun onAttachedToActivity(activityPluginBinding: io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding) {
        this.activity = activityPluginBinding.activity
    }

    override fun onDetachedFromActivity() {
        // Clean up if needed
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Clean up if needed
    }

    override fun onReattachedToActivityForConfigChanges(activityPluginBinding: io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding) {
        this.activity = activityPluginBinding.activity
    }

    private fun getScreenCornerRadii(view: View): Map<String, Double>? {
        // Default to zero radii
        val result = mutableMapOf(
            "topLeft" to 0.0,
            "topRight" to 0.0,
            "bottomLeft" to 0.0,
            "bottomRight" to 0.0,
        )

        val density = this.activity.resources.displayMetrics.density.toDouble()
        if (density == 0.0) {
            return null
        }

        // API 31+ has RoundedCorner via WindowInsets
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                val insets = view.rootWindowInsets
                val tl = insets.getRoundedCorner(android.view.RoundedCorner.POSITION_TOP_LEFT)?.radius ?: 0
                val tr = insets.getRoundedCorner(android.view.RoundedCorner.POSITION_TOP_RIGHT)?.radius ?: 0
                val bl = insets.getRoundedCorner(android.view.RoundedCorner.POSITION_BOTTOM_LEFT)?.radius ?: 0
                val br = insets.getRoundedCorner(android.view.RoundedCorner.POSITION_BOTTOM_RIGHT)?.radius ?: 0
                result["topLeft"] = tl.toDouble() / density
                result["topRight"] = tr.toDouble() / density
                result["bottomLeft"] = bl.toDouble() / density
                result["bottomRight"] = br.toDouble() / density
                return result
            } catch (_: Throwable) {
                // fall through to resource-based
            }
        }

        // Fallback: common OEM resource (mirrors approach used in community plugins)
        val res = context.resources
        val resId = res.getIdentifier("rounded_corner_radius", "dimen", "android")
        if (resId != 0) {
            val px = res.getDimensionPixelSize(resId)
            val v = px.toDouble()
            result["topLeft"] = v
            result["topRight"] = v
            result["bottomLeft"] = v
            result["bottomRight"] = v
            return result
        }

        return null
    }

}
