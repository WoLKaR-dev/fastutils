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

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fastutils/fastutils.dart';

/// This Interface was made to be implemented as a `DataService` singleton
abstract class DataServiceInterface {
  /// Current data path
  String? _path;

  //==============
  //============== Web Methods
  //==============

  /// Intializes web directories.
  /// NOTE: This method can be overriden with your own implementation.
  ///
  /// Returns `true` if the initialization was successful, or `false` otherwise.
  Future<bool> initWebDirectory() async {
    final result = FastUtilsWeb().initWebDirectories([
      WebPersistenceMode.indexedDB,
    ]);
    return result;
  }

  /// Writes web files.
  /// NOTE: This method can ve overriden with your own implementation.
  ///
  /// - [fileOrKeyName] as the file name
  /// - [content] as the content to store
  /// - [ext] as the file extension
  ///
  /// Returns `true` if the file was written successfully, `false` otherwise.
  Future<bool> writeWebFile(
    String fileOrKeyName,
    String content,
    String ext,
  ) async {
    final result = await FastUtilsWeb().writeIndexedKey(
      '$fileOrKeyName.$ext',
      content,
    );
    return result;
  }

  /// Reads web files
  /// NOTE: this method can be overriden with your own implementation.
  ///
  /// - [fileOrKeyName] as the file name
  /// - [ext] as the file extension
  ///
  /// Returns file content if success, empty string if failed.
  Future<String> readWebFile(String fileOrKeyName, String ext) async {
    final result =
        await FastUtilsWeb().readIndexedKey('$fileOrKeyName.$ext') as String?;
    return result ?? "";
  }

  /// Removes web files
  /// NOTE: this method can be overriden with your own implementation.
  ///
  /// - [fileOrKeyName] as the file name
  /// - [ext] as the file extension
  ///
  /// Returns `true` if deletion was successful, `false` otherwise
  Future<bool> deleteWebFile(String fileOrKeyName, String ext) async {
    final result = await FastUtilsWeb().deleteIndexedKey('$fileOrKeyName.$ext');
    return result;
  }

  /// Searches web files
  /// NOTE: this method can be overriden with your own implementation.
  ///
  /// - [fileOrKeyName] as the file name
  /// - [ext] as the file extension
  ///
  /// Returns `true` if file was found, `false` otherwise
  Future<bool> searchWebFile(String fileOrKeyName, String ext) async {
    final exists = await FastUtilsWeb().indexedDBKeyExists(
      '$fileOrKeyName.$ext',
    );
    return exists;
  }

  //==============
  //==============  DataServiceMethods
  //==============

  /// Initializes directories
  ///
  /// [directoryName] is the name of the folder where the data must be saved
  Future<void> initDirectories(String directoryName) async {
    switch (FastUtils().device) {
      case Device.web:
        final result = await initWebDirectory();
        if (result) {
          _path = "";
        }
        break;
      case Device.android:
        await _initAndroidDir();
        break;
      case Device.linux:
        await _initDesktopDir(directoryName = directoryName);
        break;
      case Device.windows:
        await _initDesktopDir(directoryName = directoryName);
        break;
      default:
        break;
    }
    DebugService().addMessage(
      '📁 Init directories triggered: $_path',
      DebugMessageType.success,
    );
  }

  /// Writes a file
  ///
  /// [name] is the file name and
  /// [data] is the content to write in the file
  /// [ext] is the file extension. by default `json`.
  ///
  /// Returns `true` if the file was written successfully, `false` otherwise
  Future<bool> writeFile(
    String name,
    String data, {
    String? ext = "json",
    bool? encrypt = true,
  }) async {
    try {
      // Check if path does not exist
      if (_path == null) throw Exception("Path is null.");

      // Saves for web devices
      if (FastUtils().device == Device.web) {
        final bool result = await writeWebFile(name, data, ext!);
        if (!result) throw Exception("🛑 Unable to save web data.");
        DebugService().addMessage(
          "[💾DataService] Web data saved successfully",
          DebugMessageType.success,
        );
        return true;
      }

      // Saves for android, linux and windows
      if ([
        Device.android,
        Device.linux,
        Device.windows,
      ].contains(FastUtils().device)) {
        // Create file
        File file = await File("${_path!}/$name.$ext").create(recursive: true);

        // Encode if asked to
        if (encrypt! && FastUtils().device == Device.android) {
          final encodedContent = await FastUtilsCryptoService().decryptContent(
            FastUtils().appName,
            data,
          );
          if (encodedContent == null) throw Exception("Encription failed. ");
          data = encodedContent;
        }

        await file.writeAsString(data, flush: true);
        DebugService().addMessage(
          "[💾DataService] Data saved successfully",
          DebugMessageType.success,
        );
        return true;
      }

      throw ("🛑 Current device did not match any of the available devices.");
    } catch (e) {
      DebugService().addMessage(
        "[💾DataService] An error occurred writing file: $e",
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Reads a file
  ///
  /// [name] is the file name and
  /// [ext] is the file extension. by default `json`.
  ///
  /// Returns the content as [String]
  Future<String> readFile(
    String name, {
    String? ext = "json",
    bool? decrypt = true,
  }) async {
    try {
      // Check if path does not exist
      if (_path == null) throw Exception("Path is null.");

      // Reads for web devices
      if (FastUtils().device == Device.web) {
        final String result = await readWebFile(name, ext!);
        if (result.isEmpty) throw Exception("🛑 Unable to read web data.");
        DebugService().addMessage(
          "[💾DataService] Web data readed successfully",
          DebugMessageType.success,
        );
        return result;
      }

      // Reads for android, linux and windows
      if ([
        Device.android,
        Device.linux,
        Device.windows,
      ].contains(FastUtils().device)) {
        // Create file, read content
        File file = await File("${_path!}/$name.$ext").create(recursive: true);
        String content = await file.readAsString();

        // Decrypt if asked to
        if (decrypt! &&
            await FastUtilsCryptoService().isEncrypted(content) &&
            FastUtils().device == Device.android) {
          final decryptedContent = await FastUtilsCryptoService()
              .decryptContent(FastUtils().appName, content);
          if (decryptedContent == null) throw Exception("Decrypt failed. ");
          content = decryptedContent;
        }

        DebugService().addMessage(
          "[💾DataService] Data read successfully",
          DebugMessageType.success,
        );

        return content;
      }

      throw ("🛑 Current device did not match any of the available devices.");
    } catch (e) {
      DebugService().addMessage(
        "[💾DataService] An error occurred reading file: $e",
        DebugMessageType.error,
      );
      return "";
    }
  }

  /// Deletes an existing file.
  ///
  /// - [name] as the file name to delete
  /// - [ext] as the file extension. Defaults to 'json'.
  ///
  /// Returns `true` if deleted successfully, `false` otherwise.
  Future<bool> deleteFile(
    String name, {
    String? ext = 'json',
  }) async {
    try {
      // Reject operation if path is null.
      if (_path == null) throw Exception('Path was null. ');

      // Handle for Web
      if (FastUtils().device == Device.web) {
        final result = await deleteWebFile(name, ext!);
        if (!result) return false;
      }

      // Handle for Windows, Linux & Android
      if ([
        Device.windows,
        Device.linux,
        Device.android,
      ].contains(FastUtils().device)) {
        // Delete file
        final File file = File('$_path/$name.$ext}');
        await file.delete();
      }

      return true;
    } catch (e, st) {
      DebugService().addMessage(
        '[ 💾DataService] An error ocurred deleting file: $e',
        DebugMessageType.error,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Searchs for a file in [_path]
  ///
  /// - [name] as the file name to search
  /// - [ext] as a possible extension. Defaults to `'json'`.
  ///
  /// Returns [FileSearchStatus.found] if file exists,
  /// [FileSearchStatus.notFound] of file does not exist or
  /// [FileSearchStatus.error] if an error occurred.
  Future<FileSearchStatus> searchFile(
    String name, {
    String? ext = 'json',
  }) async {
    try {
      // variable to save status
      bool exists = false;

      // Check that path is not null.
      if (_path == null) throw Exception('Path is null');

      // Search in web
      if (FastUtils().device == Device.web) {
        exists = await searchWebFile(name, ext!);
      }

      // Search in windows, linux & android
      if ([
        Device.android,
        Device.windows,
        Device.linux,
      ].contains(FastUtils().device)) {
        final File file = File('$_path/$name.$ext!');
        exists = await file.exists();
      }

      // Return status
      if (exists) return FileSearchStatus.found;

      return FileSearchStatus.notFound;
    } catch (e, st) {
      DebugService().addMessage(
        '[ 💾DataService] An error ocurred : $e',
        DebugMessageType.error,
        stackTrace: st,
      );
      return FileSearchStatus.error;
    }
  }

  /// Initializes android directory
  Future<void> _initAndroidDir() async {
    final uri = await getApplicationSupportDirectory();
    _path = uri.path;
  }

  /// Initializes desktop directories (linux, windows)
  ///
  /// Requires a [directoryName] that is the name of the folder
  /// where the data must be saved
  Future<void> _initDesktopDir(String directoryName) async {
    final uri = await getApplicationDocumentsDirectory();
    _path = Uri.parse("${uri.path}/$directoryName").path;
  }

  //==============
  //============== Getters
  //==============

  /// Returns if the path is selected
  bool get directorySelected => _path != null;

  /// Updates service path
  set path(String newPath) {
    _path = newPath;
  }
}

/// Interface designed to handle the app data.
abstract class AppDataServiceInterface {
  //==============
  //============== Attributes
  //==============

  //==============
  //============== Constructors
  //==============

  //==============
  //============== Methods
  //==============

  /// Loads user data, using readFile
  Future<bool> loadData();

  /// Saves user data, using saveFile
  Future<bool> saveData();

  /// Creates or gets a secret key, and aliases it.
  /// This method uses [FastUtilsCryptoService] as background.
  /// This is only available on Android.
  ///
  /// - [alias] as the alias of the secret key
  ///
  /// Returns the secret key that was created or retrieved. `null` if failed.
  ///
  /// Example:
  /// ```
  /// final secretKey = await getOrCreateSecretKey('my_secret_key');
  /// ```
  Future<String?> getOrCreateSecretKey(String alias) async {
    if (FastUtils().device != Device.android) return null;
    final cryptoService = FastUtilsCryptoService();
    final fastUtils = FastUtils();
    final exists = await cryptoService.existsSharedPreferencesKey(
      fastUtils.appName,
      alias,
    );
    if (exists) {
      final secretKey = await cryptoService.getSharedPreferencesValue(
        fastUtils.appName,
        alias,
      );
      return secretKey;
    } else {
      final secretKey = generateId(amount: 20);
      final result = await cryptoService.putSharedPreferencesValue(
        fastUtils.appName,
        alias,
        secretKey,
      );
      return result ? secretKey : null;
    }
  }

  /// Removes an existing secret key.
  /// This method uses [FastUtilsCryptoService] as background.
  /// This is only available on Android.
  ///
  /// - [alias] as the alias to remove secret key
  ///
  /// Returns `true`if the secret key was removed successfully,
  /// otherwise `false` if it does not exist.
  ///
  /// Example:
  /// ```
  /// final result = await removeSecretKey('my_secret_key');
  /// if (result) {
  ///    print('Secret key removed successfully');
  ///  } else {
  ///    print('Secret key does not exist');
  ///  }
  /// ```
  Future<bool> removeSecretKey(String alias) async {
    if (FastUtils().device != Device.android) return false;
    final cryptoService = FastUtilsCryptoService();
    final fastUtils = FastUtils();
    return await cryptoService.removeSharedPreferencesValue(
      fastUtils.appName,
      alias,
    );
  }

  //==============
  //============== Getters
  //==============

  //==============
  //============== Getter Functions
  //==============
}
