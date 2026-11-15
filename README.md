# FastUtils

![LICENSE](https://img.shields.io/github/license/wolkar-dev/fastutils)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-34A853?style=flat&logo=android&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)

FastUtils is a Flutter Plugin aimed at speeding development process in Flutter Apps.
It provides a set of utility functions that reduce the need to write boilerplate code for common tasks.

# Installation

FastUtils is not available via `pub.dev` you must add it manually pasting

```yaml
fastutils:
  git:
    url: https://github.com/wolkar-dev/fastutils
```

in your `pubspec.yaml` file.

# Initialization

The following example shows how to initialize FastUtils in your main.dart file.

```dart
import 'package:fastutils/fastutils.dart'; // Import FastUtils (use your correct location) 
import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

/// Main App Stateless Page. 
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FastUtils",
      // theme: appTheme, // You can add your theme here
      home: MainAppPage(),
    );
  }
}

/// Main App Page (here we initialize services, load data, and more. )
class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {

  late Future<void> _init;

  @override
  void initState() {
    _init = initialize();
    super.initState();
  }

  Future<void> initialize() async {
    await Future.delayed(Duration.zero); // this is mandatory. 

    if (mounted) FastUtils().initFastUtils(context, "appName");
    // Important: appName must be constant over app versions. Otherwise, 
    // data could be lost. 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If loaded, you can use here FastUtils components
            return Scaffold(body: Background(child: Scroll(children: [])));
          } else {
            // Else, load your splash screen or loading indicator
            // DO NOT use here FastUtils components, because they will not be initialized yet
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        }
    );
  }
}
```

# Usage Guide

## Saving data with FastUtils

FastUtils allows you to save data easily with just a few lines of code. Here's an example:

```dart
// data_service.dart
class DataService extends DataServiceInterface {
  // This class has lots of methods to save data.

  /// Singleton main instance
  static final DataService _instance =
  DataService._internal();

  /// Private internal constructor
  DataService._internal();

  /// Factory constructor
  factory DataService() => _instance;

}

// appdata_service.dart
class AppDataService extends AppDataServiceInterface {
  // You must implement here: 

  /// Singleton main instance
  static final AppDataService _instance =
  AppDataService._internal();

  /// Private internal constructor
  AppDataService._internal();

  /// Factory constructor
  factory AppDataService() => _instance;

  /// Loads user data, using readFile
  @override
  Future<bool> loadData() async {
    // other code
  }

  /// Saves user data, using saveFile
  @override
  Future<bool> saveData() async {
    // other code
  }

// You can implement those methods using DataService methods: 
// Future<bool> saveData() async {
//   return DataService.writeFile(// other code); 
// }
}
```

You can take a look at `DataServiceInterface` and at `AppDataServiceInterface` to see available methods.

If you want to use `DataService`, remember to execute `DataService().initDirectories(// other code)` in app initialization:

```dart
// other codeFuture<void> initialize() async {
await Future.delay(Duration.none); // Must be included
if (mounted) FastUtils().initFastUtils(context, 'test_app');
await DataService().initDirectories(FastUtils().appName);
}
// other code
```

### Securing databases with FastUtils on Android
You can encrypt your Android Drift databases with FastUtils using `AppDataService`: 
```dart
// other code
await secretKey = await getOrCreateSecretKey('mi_key_alias');
if (secretKey != null){
// Use this secret key to encrypt database. The secret key is securely stored.
}
// other code
```


