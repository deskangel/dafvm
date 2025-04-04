import 'dart:io';
import 'package:path/path.dart' as p;

bool prepareProjectFiles(String path) {
  print('\nDealing with project files [6]...');

  if (replaceMain(path)) {
    print('** [1] Succeeded to prepare the lib/main.dart file');
  }

  if (createHome(path)) {
    print('** [2] Succeeded to prepare the lib/home.dart file');
  }

  if (createNotifier(path)) {
    print('** [3] Succeeded to prepare the lib/model/main_notifier.dart file');
  }

  if (createi18n(path)) {
    print('** [4] Succeeded to prepare the assets/i18n/en.json and assets/i18n/zh.json files');
  }

  if (copyLogo(path)) {
    print('** [5] Succeeded to prepare the assets/images/logo.png');
  }

  if (fixTestAppName(path)) {
    print('** [6] Succeeded to change the Widget name from MyApp to MainApp in test/widget_test.dart');
  }

  return true;
}

const mainContent = '''
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'model/main_notifier.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      path: 'assets/i18n',
      supportedLocales: const [Locale('en'), Locale('zh')],
      useFallbackTranslations: true,
      fallbackLocale: const Locale('en'),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MainNotifier()),
        ],
        child: const HomePage(),
      ),
    );
  }
}
''';

bool replaceMain(String path) {
  var file = File(p.join(path, 'lib', 'main.dart'));
  if (!file.existsSync()) {
    print('\t- lib/main.dart file does not exist.');
    return false;
  }

  file.writeAsStringSync(mainContent);

  return true;
}

const homeContent = '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/main_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer<MainNotifier>(
                        builder: (context, notifier, widget) {
                          return const SelectableText('hello');
                        }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(onPressed: () {}, child: const Text('Next')),
        ],
      ),
    );
  }
}
''';

bool createHome(String path) {
  final file = File(p.join(path, 'lib', 'home.dart'));
  if (file.existsSync()) {
    print('\t- lib/home.dart seems already exist.');
    return false;
  }

  file.writeAsStringSync(homeContent);
  return true;
}

const notifierContent = '''
import 'package:flutter/material.dart';

class MainNotifier with ChangeNotifier {

}
''';

bool createNotifier(String path) {
  final dir = Directory(p.join(path, 'lib', 'model'));
  if (!dir.existsSync()) {
    dir.createSync();
  }

  final file = File(p.join(path, 'lib', 'model', 'main_notifier.dart'));
  if (file.existsSync()) {
    print('\t- lib/model/main_notifier.dart seems already exist.');
    return false;
  }

  file.writeAsStringSync(notifierContent);
  return true;
}

bool createi18n(String path) {
  final dir = Directory(p.join(path, 'assets', 'i18n'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final enFile = File(p.join(path, 'assets', 'i18n', 'en.json'));
  enFile.writeAsStringSync('{}');

  final zhFile = File(p.join(path, 'assets', 'i18n', 'zh.json'));
  zhFile.writeAsStringSync('{}');

  return true;
}

bool copyLogo(String path) {
  final dir = Directory(p.join(path, 'assets', 'images'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  var logoFile = File(p.join(dir.path, 'logo.png'));
  if (logoFile.existsSync()) {
    print('\t- assets/images/logo.png seems already exist.');
    return false;
  }

  final imgFile = File(p.join(path, 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png'));

  try {
    imgFile.copySync(logoFile.path);
  } catch (e) {
    print('\t- failed to copy ${imgFile.path} to ${logoFile.path}');
    return false;
  }

  return true;
}

bool fixTestAppName(String path) {
  final testFile = File(p.join(path, 'test/widget_test.dart'));
  if (!testFile.existsSync()) {
    print('\t- test/widget_test.dart file does not exist.');
    return false;
  }

  final content = testFile.readAsStringSync();
  testFile.writeAsStringSync(content.replaceFirst('MyApp', 'MainApp'));
  return true;
}
