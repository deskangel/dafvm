import 'dart:io';
import 'package:path/path.dart' as p;

bool prepareProjectFiles(String path) {
  print('\nDealing with project files [8]...');

  if (_replaceMain(path)) {
    print('** [1] Succeeded to prepare the lib/main.dart file');
  }

  if (_createHome(path)) {
    print('** [2] Succeeded to prepare the lib/home.dart file');
  }

  if (_createNotifiers(path)) {
    print('** [3] Succeeded to prepare the notifier files');
  }

  if (_createi18n(path)) {
    print('** [5] Succeeded to prepare the assets/i18n/en.json and assets/i18n/zh-CN.json files');
  }

  if (_createSettings(path)) {
    print('** [6] Succeeded to prepare the lib/controller/settings.dart file');
  }

  if (_copyLogo(path)) {
    print('** [7] Succeeded to prepare the assets/images/logo.png');
  }

  if (_fixTestAppName(path)) {
    print('** [8] Succeeded to change the Widget name from MyApp to MainApp in test/widget_test.dart');
  }

  return true;
}

const mainContent = '''
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'model/notifier/main_notifier.dart';
import 'model/notifier/theme_notifier.dart';
import 'controller/settings.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      path: 'assets/i18n',
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('zh', 'CN')],
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
    context.setLocale(Settings.instance.localeName);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainNotifier()),
        ChangeNotifierProvider(create: (context) => ThemeChangeNotifier()),
      ],
      child: Consumer<ThemeChangeNotifier>(
        builder: (BuildContext context, ThemeChangeNotifier notifier, Widget? child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp(
                title: 'Title',
                onGenerateTitle: (context) => 'Title'.tr(),
                debugShowCheckedModeBanner: false,
                locale: context.locale,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                themeMode: notifier.themeMode,
                theme: ThemeData.light(useMaterial3: Settings.instance.useMaterial3).copyWith(
                  colorScheme: lightDynamic ?? ColorScheme.light(),
                ),
                darkTheme: ThemeData.dark(useMaterial3: Settings.instance.useMaterial3).copyWith(
                  colorScheme: darkDynamic ?? ColorScheme.dark(),
                ),
                home: HomePage(key: ValueKey(Settings.instance.language)),
              );
            },
          );
        },
      ),
    );
  }
}
''';

bool _replaceMain(String path) {
  var file = File(p.join(path, 'lib', 'main.dart'));
  if (!file.existsSync()) {
    print('\t- ${file.path} file does not exist.');
    return false;
  }

  file.writeAsStringSync(mainContent);

  return true;
}

const homeContent = '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/notifier/main_notifier.dart';

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

bool _createHome(String path) {
  final file = File(p.join(path, 'lib', 'home.dart'));
  if (file.existsSync()) {
    print('\t- ${file.path} seems already exist.');
    return false;
  }

  file.writeAsStringSync(homeContent);
  return true;
}

const mainNotifierContent = '''
import 'package:flutter/material.dart';

class MainNotifier with ChangeNotifier {

}
''';

const themeNotifierContent = '''

import 'package:flutter/material.dart';

import '../../controller/settings.dart';

class ThemeChangeNotifier with ChangeNotifier {
  Brightness get brightness {
    return Settings.instance.darkMode ? Brightness.dark : Brightness.light;
  }

  ThemeMode get themeMode {
    return Settings.instance.darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  bool get useMaterial3 {
    return Settings.instance.useMaterial3;
  }

  void notify() {
    notifyListeners();
  }
}
''';

bool _createNotifiers(String path) {
  final dir = Directory(p.join(path, 'lib', 'model', 'notifier'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final mainNotifierFile = File(p.join(dir.path, 'main_notifier.dart'));
  if (mainNotifierFile.existsSync()) {
    print('\t- ${mainNotifierFile.path} seems already exist.');
  } else {
    mainNotifierFile.writeAsStringSync(mainNotifierContent);
  }

  final themeNotifierFile = File(p.join(dir.path, 'theme_notifier.dart'));
  if (themeNotifierFile.existsSync()) {
    print('\t- ${themeNotifierFile.path} seems already exist.');
  } else {
    themeNotifierFile.writeAsStringSync(themeNotifierContent);
  }

  return true;
}

const settingsContent = '''
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  factory Settings() => _getInstance();
  static Settings get instance => _getInstance();
  static Settings? _instance;

  Settings._internal();

  static Settings _getInstance() => _instance ??= Settings._internal();

  static const int COPYRIGHT_DATE = 2025;

  late SharedPreferences prefs;
  Future init({SharedPreferences? prefs}) async {
    this.prefs = prefs ?? await SharedPreferences.getInstance();

    _themeMode = this.prefs.getInt('setting.themeMode') ?? _themeMode;
    _useMaterial3 = this.prefs.getBool('setting.useMaterial3') ?? _useMaterial3;
    _language = this.prefs.getString('language') ?? _language;
  }

  ///
  /// theme mode
  ///
  static const List<String> THEME_MODE_NAMES = ['WithSystem', 'Light mode', 'Dark mode'];
  bool? deviceBrightnessCache;
  bool get darkMode {
    if (_themeMode == ThemeMode.system.index) {
      if (deviceBrightnessCache == null) {
        final Brightness brightness = PlatformDispatcher.instance.platformBrightness;
        deviceBrightnessCache = (brightness == Brightness.dark);
      }

      return deviceBrightnessCache!;
    }

    return _themeMode == ThemeMode.dark.index;
  }

  int _themeMode = ThemeMode.dark.index;
  int get themeMode => _themeMode;
  set themeMode(int value) {
    _themeMode = value;
    this.prefs.setInt('setting.themeMode', value);
  }

  bool _useMaterial3 = true;
  bool get useMaterial3 => _useMaterial3;
  set useMaterial3(bool value) {
    _useMaterial3 = value;
    this.prefs.setBool('setting.useMaterial3', value);
  }

  ///
  /// language and locale
  ///
  static const I18N_LANGUAGES = {
    'System': 'system',
    'English': 'en',
    '简体中文': 'zh-Hans-*',
    // '繁體中文': 'zh-Hant-*',
    // '繁體中文(台湾)': 'zh-Hant-TW',
  };

  String _language = 'System';
  String get language => I18N_LANGUAGES.containsKey(_language) ? _language : 'System';
  set language(String lang) {
    _language = lang;
    this.prefs.setString('language', _language);
  }

  Locale get localeName {
    var lang = I18N_LANGUAGES[_language] ?? 'en';
    if (lang == 'system') {
      var localeParts = Platform.localeName.split('_');
      if (localeParts.contains('zh')) {
        return const Locale('zh', 'CN');
      } else if (localeParts.contains('Hans') || localeParts.contains('CN')) {
        return const Locale('zh', 'CN');
        // } else if (localeParts.contains('TW')) {
        //   return const Locale('zh', 'TW');
        // } else if (localeParts.contains('Hant') || localeParts.contains('HK')) {
        //   return const Locale('zh', 'HK');
      } else {
        return const Locale('en');
      }
    } else if (lang == 'zh-Hans-*') {
      return const Locale('zh', 'CN');
      // } else if (lang == 'zh-Hant-TW') {
      //   return const Locale('zh', 'TW');
      // } else if (lang == 'zh-Hant-*') {
      //   return const Locale('zh', 'HK');
    }

    return Locale(lang);
  }

  /// --------------------------------------------------------------------------
}
''';

bool _createSettings(String path) {
  final dir = Directory(p.join(path, 'lib', 'controller'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File(p.join(dir.path, 'settings.dart'));
  if (file.existsSync()) {
    print('\t- ${file.path} seems already exist.');
    return false;
  }
  file.writeAsStringSync(settingsContent, flush: true);
  return true;
}

bool _createi18n(String path) {
  final dir = Directory(p.join(path, 'assets', 'i18n'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final enFile = File(p.join(dir.path, 'en.json'));
  if (enFile.existsSync()) {
    print('\t- ${enFile.path} seems already exist.');
  } else {
    enFile.writeAsStringSync('{}');
  }

  final zhFile = File(p.join(dir.path, 'zh-CN.json'));
  if (zhFile.existsSync()) {
    print('\t- ${zhFile.path} seems already exist.');
  } else {
    zhFile.writeAsStringSync('{}');
  }

  return true;
}

bool _copyLogo(String path) {
  final dir = Directory(p.join(path, 'assets', 'images'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  var logoFile = File(p.join(dir.path, 'logo.png'));
  if (logoFile.existsSync()) {
    print('\t- ${logoFile.path} seems already exist.');
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

bool _fixTestAppName(String path) {
  final testFile = File(p.join(path, 'test/widget_test.dart'));
  if (!testFile.existsSync()) {
    print('\t- test/widget_test.dart file does not exist.');
    return false;
  }

  final content = testFile.readAsStringSync();
  testFile.writeAsStringSync(content.replaceFirst('MyApp', 'MainApp'));
  return true;
}
