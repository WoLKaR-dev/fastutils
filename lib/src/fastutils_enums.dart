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

enum RoundedButtonIconPosition { left, right }

/// Different kind of supported devices of FastUtils.
enum Device {
  /// Android devices
  android,

  /// Web files
  web,

  /// iOS devices.
  /// NOTE: iOS is not yet fully available in FastUtils
  ios,

  /// Windows devices
  windows,

  /// macOS devices.
  /// NOTE: macOS is not yet fully available in FastUtils
  macos,

  /// Linux devices.
  linux,
}

enum ScreenSize { small, regular, large, xlarge, xxlarge }

/// Different web persistence modes.
///
/// - [WebPersistenceMode.session] must be used when data is saved directly
/// in the browser, without using system files.
/// - [WebPersistenceMode.file] should be used when we want the user to have
/// control over the data, that is saved in a previously picked folder.
enum WebPersistenceMode {
  /// Saves data within sessions. Max size: 5MB.
  /// This mode allows only so save key-value pairs.
  /// Only allows to store [String].
  localStorage,

  /// Is a NoSQL database integrated in web browser. Can save objects,
  /// blobs, etc. Can store hundreds of MB.
  indexedDB,

  /// User is able to select a folder in which to save data.
  /// No practical size limit.
  fileSystemAccessApi,
}

typedef JSON = Map<String, dynamic>;

/// Determines file search status
enum FileSearchStatus {
  /// The file was successfully found.
  found,

  /// File was not found.
  notFound,

  /// An error occurred while searching for file.
  /// This file could exist or not.
  error,
}
