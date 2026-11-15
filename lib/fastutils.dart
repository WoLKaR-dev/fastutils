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

export 'src/fastutils_enums.dart';
export 'src/fastutils_extensions.dart';
export 'src/fastutils_styles.dart';
export 'src/fastutils_code.dart';
export 'src/fastutils_data.dart';
export 'src/fastutils_debug.dart';
export 'src/web/fastutils_web.dart';
export 'src/crypto/fastutils_crypto_service.dart';
export 'src/fastutils_interfaces.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'src/fastutils_enums.dart';

/// Clase principal de uso general de wolkarutils
class FastUtils {
  //==============
  //============== Atributos
  //==============

  /// Tipo de dispositivo usado
  late Device _device;

  /// Tamaño de dispositivo usado
  late ScreenSize _screenSize;

  /// Color pallete de dispositivo
  late ColorScheme _colorPalette;

  /// App name
  late String _appName;

  /// Instancia unica del singleton
  static final FastUtils _instance = FastUtils._internal();

  /// Temas de la app
  late ThemeData _theme;

  //==============
  //============== Constructor interno
  //==============

  /// Constructor interno
  FastUtils._internal();

  /// Constructor interno privado
  factory FastUtils() => _instance;

  //==============
  //============== Metodos
  //==============

  /// Initializes FastUtils
  ///
  /// [context] as required context.
  ///
  /// Example:
  /// ```dart
  /// ... // Main App initialization
  /// class MainApp extends StatelessWidget{
  ///  ...
  ///   return MaterialApp(
  ///     title: 'AppName',
  ///     home: MainAppPage(),
  ///     theme: appTheme(),
  ///   )
  /// }
  ///
  /// ... // Stateful Initialization
  /// class _MainAppPageState extends State<MainAppPage> {
  ///   late Future<void> _initialization;
  ///
  ///   @override
  ///   initState(){
  ///     _initialization = initialize()
  ///     super.initState();
  ///   }
  ///
  ///   Future<void> initialize() async {
  ///     await Future.delay(Duration.none); // Must be included
  ///     if (mounted) FastUtils().initFastUtils(context, 'appName');
  ///   }
  ///
  ///   ... // Widget build
  ///   return FutureBuilder(
  ///     future: _initialization,
  ///     builder: ((context, snapshot) {
  ///       if (snapshot.connectionState == ConnectionState.done) {
  ///         return NavigationPage(); // Initialize app.
  ///       } else {
  ///         return Scaffold(
  ///           body: Center(child: CircularProgressIndicator())
  ///         ); // Initialize a safe screen.
  ///       }
  ///     }
  ///   );
  ///   ...
  /// }
  /// ```
  void initFastUtils(BuildContext context, String appName) {
    _theme = Theme.of(context);
    _colorPalette = _theme.colorScheme;
    _appName = appName;
    _initDevice();
    _initScreenSize(context);
  }

  /// Inicializa el tipo de dispositivo de la app
  void _initDevice() {
    if (kIsWeb) {
      _device = Device.web;
      return;
    } else if (Platform.isAndroid) {
      _device = Device.android;
    } else if (Platform.isLinux) {
      _device = Device.linux;
    } else if (Platform.isWindows) {
      _device = Device.windows;
    } else if (Platform.isMacOS) {
      _device = Device.macos;
    } else if (Platform.isIOS) {
      _device = Device.ios;
    }
  }

  /// Inicializa el tipo de pantalla
  ///
  /// [context] de tipo [BuildContext] para poder leer los tamaños
  void _initScreenSize(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width < 320) {
      _screenSize = ScreenSize.small;
    } else if (width <= 425) {
      _screenSize = ScreenSize.regular;
    } else if (width < 768) {
      _screenSize = ScreenSize.large;
    } else if (width < 1024) {
      _screenSize = ScreenSize.xlarge;
    } else {
      _screenSize = ScreenSize.xxlarge;
    }
  }

  //==============
  //============== Getters
  //==============

  /// Tamaño de pantalla de dispostivo
  ScreenSize get screenSize => _screenSize;

  /// Tipo de dispositivo
  Device get device => _device;

  /// Paleta de color de la app
  ColorScheme get colorPalette => _colorPalette;

  /// App Name
  String get appName => _appName;

  /// Temas de la app
  ThemeData get theme => _theme;
}
