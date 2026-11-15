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
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'package:fastutils/fastutils.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class FastUtilsWeb {
  //==============
  //============== Attributes
  //==============

  /// Singleton main instance
  static final FastUtilsWeb _instance = ._internal();

  /// Directory handle
  web.FileSystemDirectoryHandle? handle;

  /// Storage
  web.Storage? storage;

  /// Indexed DataBase
  web.IDBDatabase? indexedDB;

  /// Storage Mode
  final Set<WebPersistenceMode> _persistenceModes = {};

  //==============
  //============== Constructors
  //==============

  /// Private internal constructor
  FastUtilsWeb._internal();

  /// Factory constructor
  factory FastUtilsWeb() => _instance;

  //==============
  //============== Methods
  //==============

  /// Initializes web directories
  ///
  /// - [mode] as the browser saving mode.
  /// - [persistentHandle] only has effects if using the initialization mode
  /// [WebPersistenceMode.fileSystemAccessApi]. If `true`, FastUtils will store
  /// the directory handler in an IndexedDB entry so the user
  /// will not need to select folder each time web app is initted. Note that if
  /// `true` [WebPersistenceMode.indexedDB] will be initialized too. Defaults
  /// to `false`.
  ///
  /// Returns `true` if directory was created, otherwise `false`.
  Future<bool> initWebDirectories(
    List<WebPersistenceMode> modes, {
    bool? persistentHandle = false,
  }) async {
    // Define initializations
    final List<bool> initializations = [];
    for (final mode in modes) {
      final res = switch (mode) {
        WebPersistenceMode.localStorage => initLocalStorage(),
        WebPersistenceMode.indexedDB => await initIndexedDB(),
        WebPersistenceMode.fileSystemAccessApi => await initFileSystemAccessApi(
          persistentHandle!,
        ),
      };
      initializations.add(res);
    }

    // Check initializations
    return !initializations.any((v) => v == false);
  }

  /// Checks if a [WebPersistenceMode] is currently enabled
  ///
  /// - [mode] as the mode to check
  ///
  /// Returns `true` if mode is enabled, otherwise `false`.
  bool isModeInitted(WebPersistenceMode mode) {
    // Check if registered
    final registered = _persistenceModes.contains(mode);

    // Confirm if mode is initialized
    return switch (mode) {
      WebPersistenceMode.localStorage => (registered && storage != null),
      WebPersistenceMode.indexedDB => (registered && indexedDB != null),
      WebPersistenceMode.fileSystemAccessApi => (registered && handle != null),
    };
  }

  //==============
  //============== [WebPersistenceMode.localStorage] Methods.
  //==============

  /// Initializes localStorage service. New Storage attribute will be available.
  ///
  /// Returns `true` if successfully initted or `false` otherwise
  bool initLocalStorage() {
    try {
      if (isModeInitted(WebPersistenceMode.localStorage)) return true;
      storage = web.window.localStorage;
      _persistenceModes.add(WebPersistenceMode.localStorage);
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / initLocalStorage]: An error ocurred'
        ' initializing localStorage: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Checks if a key exists in the storage.
  ///
  /// - [key] as the key to check
  ///
  /// Returns `true` if key exists, otherwise `false`.
  bool localStorageKeyExists(String key) {
    try {
      if (!isModeInitted(WebPersistenceMode.localStorage)) {
        throw UnimplementedError('Not supported persistence mode');
      }

      final handle = web.window.localStorage;
      return handle.getItem(key) != null;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / existsLocalStorageKey]:'
        ' An error ocurred checking the key $key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Adds a new key to the storage.
  ///
  /// - [key] as the key to add
  /// - [content] as the content to write
  ///
  /// Returns `true` if successful, otherwise `false`.
  bool writeLocalStorageKey(String key, String content) {
    try {
      if (!isModeInitted(WebPersistenceMode.localStorage)) {
        throw UnimplementedError('Not supported persistence mode');
      }

      final handle = web.window.localStorage;
      handle.setItem(key, content);
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / writeLocalStorageKey]:'
        ' An error ocurred writing the key $key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Reads a key from the storage.
  ///
  /// - [key] as the key to read
  ///
  /// Returns the content of the key if found, otherwise `null`.
  String? readLocalStorageKey(String key) {
    try {
      if (!isModeInitted(WebPersistenceMode.localStorage)) {
        throw UnimplementedError('Not supported persistence mode');
      }
      final handle = web.window.localStorage;
      final content = handle.getItem(key);
      return content;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / readKey]:'
        ' An error ocurred reading the key $key, $e',
        DebugMessageType.error,
      );
      return null;
    }
  }

  /// Removes a key from the storage.
  ///
  /// - [key] as the key to remove
  ///
  /// Returns `true` if the key was removed, `false` otherwise.
  bool deleteLocalStorageKey(String key) {
    try {
      if (!isModeInitted(WebPersistenceMode.localStorage)) {
        throw UnimplementedError('Not supported persistence mode');
      }
      web.window.localStorage.removeItem(key);
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / removeKey]:'
        ' An error ocurred removing the key $key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  //==============
  //============= [WebPersistenceMode.indexedDB]
  //==============

  /// Initializes IndexedDB
  ///
  /// Returns `true` if the initialization was successful, `false` otherwise.
  Future<bool> initIndexedDB() async {
    try {
      // if already initialized, return true
      if (isModeInitted(WebPersistenceMode.indexedDB)) return true;

      final dbName = 'fastutils';
      final storeName = FastUtils().appName;
      final completer = Completer<bool>();
      final request = web.window.indexedDB.open(dbName, 1);

      // Create IndexedDB Object Store
      request.onupgradeneeded = ((web.IDBVersionChangeEvent _) {
        final db = request.result as web.IDBDatabase;
        if (!db.objectStoreNames.contains(storeName)) {
          db.createObjectStore(storeName);
        }
      }).toJS;

      // Process successful request
      request.onsuccess = ((web.Event _) {
        indexedDB = request.result as web.IDBDatabase;

        indexedDB!.onversionchange = ((web.Event _) {
          indexedDB!.close();
        }).toJS;

        // Register initialization
        _persistenceModes.add(WebPersistenceMode.indexedDB);

        // Mark as completed
        completer.complete(true);
      }).toJS;

      // Process errors
      request.onerror = ((web.Event _) {
        DebugService().addMessage(
          '[FastUtilsWeb / initIndexedDB]: Failed to open indexedDB',
          DebugMessageType.error,
        );
        completer.complete(false);
      }).toJS;

      // Manage blockages
      request.onblocked = ((web.Event _) {
        DebugService().addMessage(
          '[FastUtilsWeb / initIndexedDB]: Open blocked by another tab',
          DebugMessageType.error,
        );
      }).toJS;

      // Return status
      return await completer.future;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / initIndexedDB]: An error ocurred initializing indexedDB: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Searches for an indexedDB key
  ///
  /// - [key] as the key to search for
  ///
  /// Returns `true` if exists, `false` otherwise
  Future<bool> indexedDBKeyExists(String key) async {
    try {
      // Check status for indexedDB
      if (!isModeInitted(WebPersistenceMode.indexedDB)) {
        throw UnimplementedError('Not supported persistence mode');
      }

      // Define completer, storeName and transaction
      final storeName = FastUtils().appName;
      final transaction = indexedDB!.transaction(storeName.toJS, 'readwrite');
      final request = transaction.objectStore(storeName).count(key.toJS);
      final completer = Completer<bool>();

      // Await for results
      request.onsuccess = ((web.Event _) {
        completer.complete(request.result.dartify() != 0);
      }).toJS;

      // Return completion
      return await completer.future;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / existsIndexedDBKey]: '
        'An error ocurred searching for key $key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Writes an indexedDB key
  ///
  /// - [key] as the key to use
  /// - [data] as the data object to write
  ///
  /// Returns `true` if success, `false` otherwise.
  Future<bool> writeIndexedKey(String key, Object data) async {
    try {
      // Check status for indexedDB
      if (!isModeInitted(WebPersistenceMode.indexedDB)) {
        throw UnimplementedError('Not supported persistence mode');
      }

      // Define completer, storeName and transaction
      final storeName = FastUtils().appName;
      final transaction = indexedDB!.transaction(storeName.toJS, 'readwrite');
      final request = transaction
          .objectStore(storeName)
          .put(data.jsify(), key.toJS);
      final completer = Completer<bool>();
      request.onsuccess = ((web.Event _) {
        completer.complete(true);
      }).toJS;

      // return results
      return await completer.future;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / writeIndexedKey]: An error ocurred'
        ' writing the key $key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Reads an IndexedDB key.
  ///
  /// - [key] as the key to read
  ///
  /// Returns the obtained object or `null` if the key wasn't found.
  Future<Object?> readIndexedKey(String key) async {
    try {
      // Reject if no info
      if (!isModeInitted(WebPersistenceMode.indexedDB)) {
        throw UnimplementedError('Not supported persistence mode');
      }

      // Define completer, storeName and transaction
      final completer = Completer<Object?>();
      final storeName = FastUtils().appName;
      final transaction = indexedDB!.transaction(storeName.toJS, 'readonly');
      final data = transaction.objectStore(storeName).get(key.toJS);

      // Process results
      data.onsuccess = ((web.Event _) {
        completer.complete(data.result.dartify());
      }).toJS;

      // Return value after completion
      return await completer.future;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / readIndexedKey]: An error ocurred'
        ' reading the key $key: $e',
        DebugMessageType.error,
      );
      return null;
    }
  }

  /// Deletes an IndexedDB key.
  ///
  /// - [key] as the key to delete
  ///
  /// Returns `true` if the key was deleted, `false` otherwise.
  Future<bool> deleteIndexedKey(String key) async {
    try {
      // Reject if no info
      if (!isModeInitted(WebPersistenceMode.indexedDB)) {
        throw UnimplementedError('Not supported persistence mode');
      }

      // Define storeName, create transaction
      final storeName = FastUtils().appName;
      final transaction = indexedDB!.transaction(storeName.toJS, 'readwrite');
      final request = transaction.objectStore(storeName).delete(key.toJS);
      final completer = Completer<bool>();

      // Process success
      request.onsuccess = ((web.Event _) {
        completer.complete(true);
      }).toJS;

      // Return status
      return await completer.future;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / deleteIndexedKey]: An error ocurred'
        'deleting the key $key: $e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  //==============
  //============= [WebPersistenceMode.fileSystemAccessApi]
  //==============

  /// Initializes fileSystemAccessApi.
  ///
  /// - [usePersistence] should equal to true if you want not to select folder manually
  /// each time the app starts. Note that enabling this option will enable
  /// [WebPersistenceMode.indexedDB] to save handler between sessions.
  ///
  /// Returns `true` if the initialization was successful, `false` otherwise.
  Future<bool> initFileSystemAccessApi(bool usePersistence) async {
    try {
      // If initted, confirm
      if (isModeInitted(WebPersistenceMode.fileSystemAccessApi)) return true;

      // Init IndexedDB if userPersistence
      if (usePersistence) {
        final indexedDbInitted = await initIndexedDB();
        if (!indexedDbInitted) throw Exception("IndexedDB not initialized. ");
        Object? obtainedHandle = await readIndexedKey('handle');
        if (!obtainedHandle.isA<web.FileSystemDirectoryHandle>()) handle = null;
        handle = obtainedHandle as web.FileSystemDirectoryHandle;
      }

      // Init FSAA
      final dirHandle = handle ?? await _jsShowDirectoryPicker();
      if (dirHandle == null) {
        throw Exception(
          ' [FastUtilsWeb / initFileSystemAccessApi]: An error ocurred',
        );
      }

      // Asign handle
      handle = dirHandle;

      // Save handle
      if (usePersistence) {
        final indexedDbInitted = await initIndexedDB();
        if (!indexedDbInitted) throw Exception("IndexedDB not initialized. ");
        writeIndexedKey('handle', handle!);
      }

      // Mark as completed
      _persistenceModes.add(WebPersistenceMode.fileSystemAccessApi);
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / initFileSystemAccessApi]: An error ocurred'
        ' initializing fileSystemAccessApi',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Checks if a file exists in a handler.
  ///
  /// - [fileName] as the file name, including extension.
  ///
  /// Returns `true` if the file exists, `false` otherwise.
  Future<bool> fileExists(String fileName) async {
    try {
      // Make Previous checks
      if (!isModeInitted(WebPersistenceMode.fileSystemAccessApi)) {
        throw Exception('fileSystemAccessApi is not initialized');
      }

      // If handle not fails, then file exists
      await handle!.getFileHandle(fileName).toDart;
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / fileExists]: An error ocurred accessing file: '
        '$e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Writes a new file with given content
  ///
  /// - [fileName] The name of the file to be written, extension included.
  /// - [content] The content of the file to be written
  ///
  /// Returns `true` if the file was written successfully, `false` otherwise.
  Future<bool> writeFile(String fileName, String content) async {
    try {
      // Make Previous checks
      if (!isModeInitted(WebPersistenceMode.fileSystemAccessApi)) {
        throw Exception('fileSystemAccessApi is not initialized');
      }

      // Get file Handle & Open Editor
      final fileHandle = await handle!
          .getFileHandle(fileName, web.FileSystemGetFileOptions(create: true))
          .toDart;
      final editor = await fileHandle.createWritable().toDart;

      // Write content & close
      await editor.write(content.toJS).toDart;
      await editor.close().toDart;
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / writeFile]: An error ocurred writing file: '
        '$e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  /// Reads a new file from the file system
  ///
  /// - [fileName] The name of the file to be read, extension included.
  ///
  /// Returns file content in String format, `null` if failed.
  Future<String?> readFile(String fileName) async {
    try {
      if (!isModeInitted(WebPersistenceMode.fileSystemAccessApi)) {
        throw Exception('fileSystemAccessApi is not initialized');
      }

      final fileHandle = await handle!.getFileHandle(fileName).toDart;
      final file = await fileHandle.getFile().toDart;
      final content = (await file.text().toDart).toDart;
      return content;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / readFile]: An error ocurred reading file: '
        '$e',
        DebugMessageType.error,
      );
      return null;
    }
  }

  /// Deletes a file from the file system
  ///
  /// - [fileName] The name of the file to be deleted, extension included.
  ///
  /// Returns `true` if the file was successfully deleted, `false` otherwise.
  Future<bool> deleteFile(String fileName) async {
    try {
      // Check mode & initialization
      if (!isModeInitted(WebPersistenceMode.fileSystemAccessApi)) {
        throw Exception('fileSystemAccessApi is not initialized');
      }

      // Remove file
      await handle!
          .removeEntry(fileName, web.FileSystemRemoveOptions(recursive: true))
          .toDart;
      return true;
    } catch (e) {
      DebugService().addMessage(
        '[FastUtilsWeb / deleteFile]: An error ocurred deleting file: '
        '$e',
        DebugMessageType.error,
      );
      return false;
    }
  }

  //==============
  //============== Getters
  //==============

  /// Gets the list of initted web modes.
  Set<WebPersistenceMode> get inittedModes => _persistenceModes;

  //==============
  //============== Getter Functions
  //==============
}

//==============
//============== Extensions & Methods
//==============

extension on web.Window {
  @JS('showDirectoryPicker')
  external JSPromise<web.FileSystemDirectoryHandle> _showDirectoryPicker([
    JSObject? options,
  ]);
}

/// Allows FastUtils to show directory picker.
///
/// Returns `null` if not supported.
Future<web.FileSystemDirectoryHandle?> _jsShowDirectoryPicker() async {
  if (!web.window.has('showDirectoryPicker')) return null;
  try {
    final options = {'mode': 'readwrite'}.jsify() as JSObject;
    return await web.window._showDirectoryPicker(options).toDart;
  } catch (e) {
    DebugService().addMessage(
      ' showDirectoryPicker Failed: $e',
      DebugMessageType.error,
    );
    return null;
  }
}
