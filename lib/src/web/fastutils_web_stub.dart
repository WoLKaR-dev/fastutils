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

/// Stub of `FastUtilsWeb`.
///
/// Provides the same public API as the original class, but without
/// real persistence implementation. Useful for tests, mocks or
/// compilation on non-web platforms.
class FastUtilsWeb {
  //==============
  //============== Attributes
  //==============

  /// Singleton main instance
  static final FastUtilsWeb _instance = FastUtilsWeb._internal();

  /// Directory handle
  // web.FileSystemDirectoryHandle? handle;
  Object? handle;

  /// Storage
  // web.Storage? storage;
  Object? storage;

  /// Indexed DataBase
  // web.IDBDatabase? indexedDB;
  Object? indexedDB;

  /// Storage Mode
  final Set<Object> _persistenceModes = {};

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
    List<Object> modes, {
    bool? persistentHandle = false,
  }) async => false;

  /// Checks if a [WebPersistenceMode] is currently enabled
  ///
  /// - [mode] as the mode to check
  ///
  /// Returns `true` if mode is enabled, otherwise `false`.
  bool isModeInitted(Object mode) => false;

  //==============
  //============== [WebPersistenceMode.localStorage] Methods.
  //==============

  /// Initializes localStorage service. New Storage attribute will be available.
  ///
  /// Returns `true` if successfully initted or `false` otherwise
  bool initLocalStorage() => false;

  /// Checks if a key exists in the storage.
  ///
  /// - [key] as the key to check
  ///
  /// Returns `true` if key exists, otherwise `false`.
  bool localStorageKeyExists(String key) => false;

  /// Adds a new key to the storage.
  ///
  /// - [key] as the key to add
  /// - [content] as the content to write
  ///
  /// Returns `true` if successful, otherwise `false`.
  bool writeLocalStorageKey(String key, String content) => false;

  /// Reads a key from the storage.
  ///
  /// - [key] as the key to read
  ///
  /// Returns the content of the key if found, otherwise `null`.
  String? readLocalStorageKey(String key) => null;

  /// Removes a key from the storage.
  ///
  /// - [key] as the key to remove
  ///
  /// Returns `true` if the key was removed, `false` otherwise.
  bool deleteLocalStorageKey(String key) => false;

  //==============
  //============= [WebPersistenceMode.indexedDB]
  //==============

  /// Initializes IndexedDB
  ///
  /// Returns `true` if the initialization was successful, `false` otherwise.
  Future<bool> initIndexedDB() async => false;

  /// Searches for an indexedDB key
  ///
  /// - [key] as the key to search for
  ///
  /// Returns `true` if exists, `false` otherwise
  Future<bool> indexedDBKeyExists(String key) async => false;

  /// Writes an indexedDB key
  ///
  /// - [key] as the key to use
  /// - [data] as the data object to write
  ///
  /// Returns `true` if success, `false` otherwise.
  Future<bool> writeIndexedKey(String key, Object data) async => false;

  /// Reads an IndexedDB key.
  ///
  /// - [key] as the key to read
  ///
  /// Returns the obtained object or `null` if the key wasn't found.
  Future<Object?> readIndexedKey(String key) async => null;

  /// Deletes an IndexedDB key.
  ///
  /// - [key] as the key to delete
  ///
  /// Returns `true` if the key was deleted, `false` otherwise.
  Future<bool> deleteIndexedKey(String key) async => false;

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
  Future<bool> initFileSystemAccessApi(bool usePersistence) async => false;

  /// Checks if a file exists in a handler.
  ///
  /// - [fileName] as the file name, including extension.
  ///
  /// Returns `true` if the file exists, `false` otherwise.
  Future<bool> fileExists(String fileName) async => false;

  /// Writes a new file with given content
  ///
  /// - [fileName] The name of the file to be written, extension included.
  /// - [content] The content of the file to be written
  ///
  /// Returns `true` if the file was written successfully, `false` otherwise.
  Future<bool> writeFile(String fileName, String content) async => false;

  /// Reads a new file from the file system
  ///
  /// - [fileName] The name of the file to be read, extension included.
  ///
  /// Returns file content in String format, `null` if failed.
  Future<String?> readFile(String fileName) async => null;

  /// Deletes a file from the file system
  ///
  /// - [fileName] The name of the file to be deleted, extension included.
  ///
  /// Returns `true` if the file was successfully deleted, `false` otherwise.
  Future<bool> deleteFile(String fileName) async => false;

  //==============
  //============== Getters
  //==============

  /// Gets the list of initted web modes.
  Set<Object> get inittedModes => _persistenceModes;
}
