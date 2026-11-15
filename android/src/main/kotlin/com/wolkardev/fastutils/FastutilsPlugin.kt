// FastUtils is an util package designed to speed up flutter development
// Copyright (C) 2026  WoLKaR-dev
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see https://www.gnu.org/licenses/.

package com.wolkardev.fastutils

import android.content.Context
import com.wolkardev.fastutils.services.FastUtilsCriptoService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FastutilsPlugin */
class FastutilsPlugin : FlutterPlugin, MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fastutils")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall, result: Result
    ) {
        when (call.method) {
            "existsSharedPreferencesKey" -> {
                val appName = call.argument<String>("appName")
                val sharedPreferenceKey = call.argument<String>("key")

                if (appName.isNullOrEmpty() || sharedPreferenceKey.isNullOrEmpty()) {
                    result.error("ARGUMENT_ERROR", "appName or key is null or empty", null)
                    return
                }

                try {
                    val exists =
                        FastUtilsCriptoService().existsSharedPreferencesKey(context, appName, sharedPreferenceKey)
                    return result.success(exists)
                } catch (e: Exception) {
                    result.error(
                        "SHARED_PREFERENCES_ERROR", e.localizedMessage, null
                    )
                }

            }

            "getSharedPreferencesValue" -> {
                val appName = call.argument<String>("appName")
                val sharedPreferenceKey = call.argument<String>("key")

                if (appName.isNullOrEmpty() || sharedPreferenceKey.isNullOrEmpty()) {
                    result.error(
                        "ARGUMENT_ERROR", "fileArray or appName is null or empty", null
                    )
                    return
                }

                try {
                    val sharedPreferenceValue = FastUtilsCriptoService().getSharedPreferencesValue(
                        context, appName, sharedPreferenceKey
                    )
                    return result.success(sharedPreferenceValue)
                } catch (e: Exception) {
                    result.error(
                        "SHARED_PREFERENCES_ERROR", e.localizedMessage, null
                    )
                }
            }

            "putSharedPreferencesValue" -> {
                val appName = call.argument<String>("appName")
                val sharedPreferenceKey = call.argument<String>("key")
                val sharedPreferenceValue = call.argument<String>("value")

                if (appName.isNullOrEmpty() ||
                    sharedPreferenceKey.isNullOrEmpty() ||
                    sharedPreferenceValue.isNullOrEmpty()
                ) {
                    result.error(
                        "ARGUMENT_ERROR", "fileArray or appName is null or empty", null
                    )
                    return
                }

                try {
                    val response = FastUtilsCriptoService().putSharedPreferencesValue(
                        context,
                        appName,
                        sharedPreferenceKey,
                        sharedPreferenceValue
                    )
                    return result.success(response)

                } catch (e: Exception) {
                    result.error(
                        "SHARED_PREFERENCES_ERROR", e.localizedMessage, null
                    )
                }

            }

            "removeSharedPreferencesValue" -> {

                val appName = call.argument<String>("appName")
                val sharedPreferenceKey = call.argument<String>("key")

                if (appName.isNullOrEmpty() || sharedPreferenceKey.isNullOrEmpty()) {
                    result.error("ARGUMENT_ERROR", "fileArray or appName is null or empty", null)
                    return
                }

                try {
                    val response = FastUtilsCriptoService().removeSharedPreferencesValue(
                        context,
                        appName,
                        sharedPreferenceKey
                    )
                    return result.success(response)
                } catch (e: Exception) {
                    result.error(
                        "SHARED_PREFERENCES_ERROR", e.localizedMessage, null
                    )
                }
            }

            "encryptFile" -> {
                val appName = call.argument<String>("appName")
                val fileBytes = call.argument<ByteArray>("fileArray")

                if (appName.isNullOrEmpty() || fileBytes == null) {
                    result.error(
                        "ARGUMENT_ERROR", "fileArray or appName is null or empty", null
                    )
                    return
                }

                try {
                    val encriptedFileBytes = FastUtilsCriptoService().encryptFile(appName, fileBytes)
                    return result.success(encriptedFileBytes)
                } catch (e: Exception) {
                    result.error(
                        "ENCODING_ERROR", e.localizedMessage, null
                    )
                }
            }

            "decryptFile" -> {
                val appName = call.argument<String>("appName")
                val encryptedFileBytes = call.argument<ByteArray>("encryptedFileArray")

                if (appName.isNullOrEmpty() || encryptedFileBytes == null) {
                    result.error(
                        "ARGUMENT_ERROR", "fileArray or appName is null or empty", null
                    )
                    return
                }

                try {
                    val decryptedFileBytes = FastUtilsCriptoService().decryptFile(
                        appName, encryptedFileBytes
                    )
                    return result.success(decryptedFileBytes)
                } catch (e: Exception) {
                    result.error(
                        "DECODING_ERROR", e.localizedMessage, null
                    )
                }
            }

            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            else -> result.notImplemented()
        }


    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
