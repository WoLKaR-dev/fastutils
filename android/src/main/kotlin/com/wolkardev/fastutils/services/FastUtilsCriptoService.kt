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

package com.wolkardev.fastutils.services

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import io.flutter.Log
import java.io.File
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.util.Dictionary
import java.util.Objects
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import  android.content.Context
import  android.content.SharedPreferences
import android.util.Base64

class FastUtilsCriptoService {
    // Transform method
    val transform = "AES/GCM/NoPadding"

    /**
     * Get or create a secret key
     * @param appName the name of the application
     * @return javax.crypto.SecretKey
     */
    fun getOrCreateKey(appName: String): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) } // Load Keystore

        if (keyStore.containsAlias("fastutils-$appName")) {
            val entry = keyStore.getEntry("fastutils-$appName", null) as KeyStore.SecretKeyEntry
            return entry.secretKey // return key if exists
        }

        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
        )
        val parameterSpec = KeyGenParameterSpec.Builder(
            "fastutils-$appName",
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,

        ).setKeySize(256)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .setUserAuthenticationRequired(false)
            .build()

        keyGenerator.init(parameterSpec)
        return keyGenerator.generateKey()
    }

    /**
     * Encrypt a file
     * @param appName the name of the application
     * @param fileArray the file to encrypt
     * @return ByteArray
     */
    fun encryptFile(appName: String, fileArray: ByteArray): ByteArray {
        val secretKey: SecretKey = getOrCreateKey(appName)
        val cipher = Cipher.getInstance(transform)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)

        val iv = cipher.iv // IV to uncrypt later
        val encryptedBytes = cipher.doFinal(fileArray)

        return iv + encryptedBytes // IV + encryptedBytes
    }

    /**
     * Decrypt a file
     * @param appName the name of the application
     * @param encryptedFileArray the file to decrypt
     * @return ByteArray
     */
    fun decryptFile(appName: String, encryptedFileArray: ByteArray): ByteArray {
        val secretKey: SecretKey = getOrCreateKey(appName)
        val iv = encryptedFileArray.copyOfRange(0, 12)
        val encryptedBytes = encryptedFileArray.copyOfRange(12, encryptedFileArray.size)

        val cipher = Cipher.getInstance(transform)
        val spec = GCMParameterSpec(128, iv)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)

        return cipher.doFinal(encryptedBytes)
    }

    /**
     * Check whether a shared preference key exists
     * @param context the context
     * @param appName the name of the application
     * @param key the key to check
     * @return Boolean if the key exists
     */
    fun existsSharedPreferencesKey(context: Context, appName: String, key: String): Boolean {
        val sp = context.getSharedPreferences("fastutils-$appName", Context.MODE_PRIVATE)
        val exists = sp.contains(key)
        return exists
    }

    /**
     * Get the value of a shared preference key and decrypts if needed.
     * @param context the context
     * @param appName the name of the application
     * @param key the key to get the value of
     * @return String the decrypted value of the key
     */
    fun getSharedPreferencesValue(context: Context, appName: String, key: String): ByteArray {
        val sp = context.getSharedPreferences("fastutils-$appName", Context.MODE_PRIVATE)
        val encryptedString = sp.getString(key, "")
        val encryptedValue = Base64.decode(encryptedString, Base64.NO_WRAP)
        val decryptedValue = decryptFile(appName, encryptedValue)
        return decryptedValue
    }

    /**
     * Save a value to a shared preference key and encrypts if needed.
     * @param context the context
     * @param appName the name of the application
     * @param key the key to save the value to
     * @param value the value to save
     * @return Boolean if the value was saved successfully
     * @throws Exception if there was an error saving the value
     */
    fun putSharedPreferencesValue(context: Context, appName: String, key: String, value: String): Boolean {
        try {
            val sp = context.getSharedPreferences("fastutils-$appName", Context.MODE_PRIVATE)
            val spEditor = sp.edit()
            val valueBytes = value.toByteArray(Charsets.UTF_8)
            val encodedValue = encryptFile(appName, valueBytes)
            val encodedString = Base64.encodeToString(encodedValue, Base64.NO_WRAP)
            spEditor.putString(key, encodedString)
            spEditor.apply()
            return true
        } catch (e: Exception) {
            Log.e("FastUtilsCriptoService", "Error saving shared preference value: $e")
            return false
        }

    }

    /**
     * Remove a value from a shared preference key.
     *  @param context the context
     *  @param appName the name of the application
     *  @param key the key to remove the value from
     *  @return Boolean if the value was removed successfully
     *  @throws Exception if there was an error removing the value
     */
    fun removeSharedPreferencesValue(context: Context, appName: String, key: String): Boolean {
        try {
            val sp = context.getSharedPreferences("fastutils-$appName", 0)
            val editor = sp.edit()
            editor.remove(key)
            editor.apply()
            return true
        } catch (e: Exception) {
            Log.e("FastUtilsCriptoService", "Error removing shared preference value: $e")
            return false
        }
    }
}