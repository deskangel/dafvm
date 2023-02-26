import 'dart:io';
import 'package:path/path.dart' as p;

bool prepareProjectFiles(String path) {
  if (!replaceMain(path)) {
    return false;
  }
  print('** Succeeded to prepare the lib/main.dart file');

  if (!createHome(path)) {
    return false;
  }
  print('** Succeeded to prepare the lib/home.dart file');

  if (!createNotifier(path)) {
    return false;
  }
  print('** Succeeded to prepare the lib/model/main_notifier.dart file');

  if (!createi18n(path)) {
    return false;
  }
  print('** Succeeded to prepare the assets/i18n/en.json and assets/i18n/zh.json files');

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
    print('lib/main.dart file does not exist.');
    return false;
  }

  file.writeAsStringSync(mainContent);

  return true;
}

const homeContent = '''
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
          const Card(child: Text('月', style: TextStyle(fontSize: 64))),
          Row(
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('yue')),
              OutlinedButton(onPressed: () {}, child: const Text('yue')),
              OutlinedButton(onPressed: () {}, child: const Text('yue')),
              OutlinedButton(onPressed: () {}, child: const Text('yue')),
            ],
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
    print('lib/home.dart seems already exist.');
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
    print('lib/model/main_notifier.dart seems already exist.');
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
