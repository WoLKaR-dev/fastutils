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

import 'dart:convert';
import 'package:fastutils/fastutils.dart';
import 'package:flutter/services.dart';

/// Handles the encryption of file content and preferences.
class FastUtilsCryptoService {
  //==============
  //============== Attributes
  //==============

  /// Singleton main instance
  static final FastUtilsCryptoService _instance =
      FastUtilsCryptoService._internal();

  /// Opened Channel
  static final _channel = MethodChannel('fastutils');

  //==============
  //============== Constructors
  //==============

  /// Private internal constructor
  FastUtilsCryptoService._internal();

  /// Factory constructor
  factory FastUtilsCryptoService() => _instance;

  //==============
  //============== Methods
  //==============

  /// Encrypts content. This is only available on Android.
  ///
  /// - [appName] as the app name
  /// - [data] as the content of the file
  ///
  /// Returns the [String] of the encrypted data or
  /// `null` if encryption failed.
  ///
  /// Example:
  /// ```dart
  /// final content = encryptContent(
  ///   'your_app_name',
  ///   'Hello World!'
  /// )
  /// if (content is null) return;
  /// // handle encrypted code
  /// ```
  Future<String?> encryptContent(String appName, String data) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      // Data array
      final dataBytesArray = Uint8List.fromList(utf8.encode(data));

      // Invoke Kotlin method
      final encryptedBytes = await _channel.invokeMethod('encryptFile', {
        'appName': appName,
        'fileArray': dataBytesArray,
      });

      // If null, return
      if (encryptedBytes == null) return null;

      // If not, convert to String and return
      String encryptedContent = base64Encode(encryptedBytes);

      // Return the encrypted content
      return encryptedContent;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / encryptContent] An error occurred '
        'encrypting content: $e',
        DebugMessageType.error,
      );
      return null;
    }
  }

  /// Decrypts file content. This is only available on Android.
  ///
  /// - [appName] as the app name
  /// - [data] as the content of the file
  ///
  /// Returns the [String] of the decrypted data or
  /// `null` if decryption failed.
  ///
  /// Example:
  /// ```dart
  /// final decryptedContent = await decryptContent(
  ///   'your_app_name',
  ///   encryptedContent
  /// )
  /// if (decryptedContent is null) return;
  /// // handle decrypted code
  /// ```
  Future<String?> decryptContent(String appName, String data) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      // Data array
      final dataBytesArray = base64Decode(data);

      // Invoke Kotlin method
      final decryptedBytes = await _channel.invokeMethod('decryptFile', {
        'appName': appName,
        'encryptedFileArray': dataBytesArray,
      });

      // If null, return
      if (decryptedBytes == null) return null;

      // If not, convert to String and return
      String decryptedContent = utf8.decode(decryptedBytes);

      // Return the decrypted content
      return decryptedContent;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / decryptContent] An error occurred '
        'decrypting content: $e',
        DebugMessageType.error,
      );
      return null;
    }
  }

  /// Determines if a String is encrypted. This is only available on Android.
  ///
  /// - [content] as the content to check
  ///
  /// Returns [true] if the String is encrypted, otherwise [false].
  ///
  /// Example:
  /// ```dart
  /// final content = 'your_encrypted_content';
  /// final isEncrypted = await isEncrypted(content);
  /// ```
  Future<bool> isEncrypted(String content) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      // If content is not multiple of 4, return false
      if (content.length % 4 != 0) return false;

      // If does not contain valid characters, return false
      if (!RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(content)) return false;

      // Try to decode the content
      try {
        base64Decode(content);
        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / isEncrypted] An error occurred '
        'checking encrypted content: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Checks if a SharedPreference key exists.
  /// This is only available on Android.
  ///
  /// - [appName] as the appName
  /// - [key] as the key to check
  ///
  /// Returns `true` if the key exists, otherwise `false`.
  ///
  /// Example:
  /// ```
  /// final exists = await existsSharedPreferencesKey(appName, key);
  /// if (exists) {
  /// ...
  /// }
  /// ```
  Future<bool> existsSharedPreferencesKey(String appName, String key) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      return await _channel.invokeMethod('existsSharedPreferencesKey', {
        'appName': appName,
        'key': key,
      });
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / existsSharedPreferencesKey] An error occurred '
        'checking sharedPreferences key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Gets a SharedPreference value linked to a key after decryption.
  /// This is only available on Android.
  ///
  /// - [appName] as the appName
  /// - [key] as the key to check
  ///
  /// Returns the value if the key exists and is decrypted, otherwise `null`.
  ///
  /// Example:
  /// ```
  /// final value = await getSharedPreferencesValue(appName, key);
  /// if (value != null) {
  /// ...
  /// }
  /// ```
  Future<String?> getSharedPreferencesValue(String appName, String key) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      final byteArray = await _channel.invokeMethod(
        'getSharedPreferencesValue',
        {'appName': appName, 'key': key},
      );
      final content = utf8.decode(byteArray as Uint8List);
      return content;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / getSharedPreferencesValue] An error occurred '
        'getting sharedPreferences value: $e',
        DebugMessageType.error,
      );
      return null;
    }
  }

  /// Writes an encrypted shared preferences value.
  /// This is only available on Android.
  ///
  /// - [appName] as the appName
  /// - [key] as the key to write
  /// - [value] as the value to write
  ///
  /// Returns `true` if the key was written, otherwise `false`.
  ///
  /// Example:
  /// ```
  /// final success = await putSharedPreferencesValue(appName, key, value);
  /// if (success) {
  /// ...
  /// }
  /// ```
  Future<bool> putSharedPreferencesValue(
    String appName,
    String key,
    String value,
  ) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      final result = await _channel.invokeMethod("putSharedPreferencesValue", {
        'appName': appName,
        'key': key,
        'value': value,
      });
      return result;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / putSharedPreferencesValue] An error occurred '
        'putting sharedPreferences value: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Removes a shared preference value.
  /// This is only available on Android.
  ///
  /// - [appName] as the appName
  /// - [key] as the key to remove
  ///
  /// Returns `true` if the key was removed, otherwise `false`.
  ///
  /// Example:
  /// ```
  /// final success = await removeSharedPreferencesValue(appName, key);
  /// if (success) {
  /// ...
  /// }
  /// ```
  Future<bool> removeSharedPreferencesValue(String appName, String key) async {
    try {
      // Reject if device is not Android
      if (FastUtils().device != Device.android) {
        throw Exception('Device is not Android');
      }

      final result = await _channel.invokeMethod(
        "removeSharedPreferencesValue",
        {'appName': appName, 'key': key},
      );
      return result;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsCryptoService / removeSharedPreferencesValue] An error occurred '
        'removing sharedPreferences value: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  //==============
  //============== Getters
  //==============

  //==============
  //============== Getter Functions
  //==============
}
