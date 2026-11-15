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
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fastutils/src/fastutils_vars.dart';
import 'package:fastutils/fastutils.dart';

/// Genera un identificador de caracteres aleatorios
///
/// [amount] número total de caracteres a generar, por defecto 15
///
/// Retorna el id generado
String generateId({int amount = 15}) {
  String chars =
      "1234567890qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPASDFGHJKLÑZXCVBNM";
  String generatedId = "";
  while (generatedId.length < amount) {
    int chosenPosition = Random.secure().nextInt(chars.length - 1);
    String selectedChar = chars[chosenPosition];
    generatedId += selectedChar;
  }
  return generatedId;
}

/// Returns a human-readable id
///
/// [locale] as the locale code. If not available, default locale is "en".
///
/// Returns generated ID
String generateHumanReadableId({String? locale = "en"}) {
  String id = "";

  for (int i = 0; i <= 2; i++) {
    // get pool names
    Map<String, List<String>> pool = (Map.from(switch (i) {
      0 => adjectives,
      1 => nouns,
      2 => verbs,
      _ => adjectives,
    }));

    // select values from local
    List<String> names = (pool[(locale!.toLowerCase())] != null
        ? pool[(locale.toLowerCase())]
        : pool["en"])!;

    // pick a random name
    final pickedName = names[Random.secure().nextInt(names.length)];

    // add to id
    id = "$id$pickedName";

    // add separator if i<2
    if (i < 2) {
      id = "$id-";
    }
  }

  return id;
}

/// Checks if the user has internet connection
///
/// - [timeoutSeconds] as the limit seconds to check connection.
///
/// Returns `true` if user has connection or `false` otherwise.
Future<bool> hasInternetConnection({int? timeoutSeconds = 5}) async {
  try {
    if (FastUtils().device == Device.web) return true;

    final result = await InternetAddress.lookup(
      "google.com",
    ).timeout(Duration(seconds: timeoutSeconds!));

    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    DebugService().addMessage(
      '[ wolkarutils_code.dart/hasInternetConnection] An error ocurred '
      'checking internet connection: $e',
      DebugMessageType.error,
    );
    return false;
  }
}

/// Returns legible dimensions for screen size.
///
/// - [context] as the BuildContext to get size.
double getLegibleDimensions(BuildContext context) {
  return switch (FastUtils().screenSize) {
    ScreenSize.small || ScreenSize.regular => MediaQuery.sizeOf(context).width,
    ScreenSize.large => MediaQuery.sizeOf(context).width * 0.7,
    ScreenSize.xlarge => MediaQuery.sizeOf(context).width * 0.4,
    ScreenSize.xxlarge => MediaQuery.sizeOf(context).width * 0.3,
  };
}

/// Returns the Lightness value that makes a HSLColor become exactly below
/// a given luminance
///
/// - [originalColor] as the color to modify
/// - [targetLuminance] as the target luminance: the closer to 1,
/// the brighter it is
double guessLightnessValue(HSLColor originalColor, double targetLuminance) {
  double lightness = 0.00;
  double luminance = 1;
  while (luminance > targetLuminance) {
    luminance = originalColor
        .withLightness(originalColor.lightness - lightness)
        .toColor()
        .computeLuminance();
    lightness += 0.0005;
  }
  return lightness;
}

/// Given a normal color, returns a legible color and its darker version.
///
/// - [baseColor] as the base color to work with
/// - [targetLuminance] as the target luminance. By default, 0.15
///
/// Returns a list of colors, where index `0` is the base color and `1` its shadow version.
List<Color> getLuminanceColorVariants(
    Color baseColor, {
      double? targetLuminance = 0.15,
    }) {
  final lightnessToRemove = guessLightnessValue(
    HSLColor.fromColor(baseColor),
    targetLuminance!,
  );

  // Define optimal color
  HSLColor optimalColor = HSLColor.fromColor(baseColor);
  optimalColor = optimalColor.withLightness(
    (optimalColor.lightness - lightnessToRemove).clamp(0, 1),
  );

  // Get Shadow Color
  HSLColor shadowColor = optimalColor.withLightness(
    (optimalColor.lightness - 0.1).clamp(0, 1),
  );

  // Return obtained data
  return [optimalColor.toColor(), shadowColor.toColor()];
}