import 'dart:io';
import 'package:path/path.dart' as p;

String _projectName = '';

bool prepareProjectFiles(String path) {
  print('\nDealing with project files [10]...');

  _projectName = getProjectName(path);

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

  if (_createSettingsPage(path)) {
    print('** [7] Succeeded to prepare the lib/view/pages/drawer/settings_page.dart file');
  }

  if (_createSidePanel(path)) {
    print('** [8] Succeeded to prepare the lib/view/pages/drawer/side_panel.dart file');
  }

  if (_copyLogo(path)) {
    print('** [9] Succeeded to prepare the assets/images/logo.png');
  }

  if (_fixTestAppName(path)) {
    print('** [10] Succeeded to change the Widget name from MyApp to MainApp in test/widget_test.dart');
  }

  return true;
}

String getProjectName(String path) {
  final file = File(p.join(path, 'pubspec.yaml'));

  String content = file.readAsStringSync();
  final lines = content.split('\n');
  for (final line in lines) {
    if (line.startsWith('name:')) {
      var name = line.split(':')[1].trim();
      // convert to camelCase
      return name[0].toUpperCase() + name.substring(1);
    }
  }

  return 'Project';
}

String mainContent = '''
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
                title: '$_projectName',
                onGenerateTitle: (context) => '$_projectName'.tr(),
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

const settingsPageContent = '''
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import '../../../controller/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr()),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Switch language'.tr(), style: const TextStyle(fontSize: 16)),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: Settings.instance.language,
                items: Settings.I18N_LANGUAGES.keys.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value == 'System' ? 'WithSystem'.tr() : value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    Settings.instance.language = value;
                  });
                  context.setLocale(Settings.instance.localeName);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';

bool _createSettingsPage(String path) {
  final dir = Directory(p.join(path, 'lib', 'view', 'pages', 'drawer'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File(p.join(dir.path, 'settings_page.dart'));
  if (file.existsSync()) {
    print('\t- ${file.path} seems already exist.');
    return false;
  }
  file.writeAsStringSync(settingsPageContent, flush: true);
  return true;
}

final String sidePanelContent = '''
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../controller/settings.dart';
import '../../../model/notifier/theme_notifier.dart';
import 'settings_page.dart';

class SidePanel extends StatefulWidget {
  const SidePanel({super.key});

  @override
  State<SidePanel> createState() => SidePanelState();
}

class SidePanelState extends State<SidePanel> {
  late ThemeChangeNotifier themeNotifier;

  @override
  void initState() {
    super.initState();

    themeNotifier = Provider.of<ThemeChangeNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: Settings.instance.darkMode ? BoxDecoration(color: Colors.grey[900]) : null,
                accountName: const Text('$_projectName'),
                accountEmail: const Text(''),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
              ),
              ListTile(
                leading: Icon(Symbols.settings),
                title: Text('Settings'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ListTile(
          leading: Tooltip(
            message: 'About'.tr(),
            child: IconButton(
              icon: const Icon(Symbols.info),
              onPressed: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();

                if (mounted) {
                  showAboutDialog(
                    context: this.context,
                    applicationIcon: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fitHeight,
                      width: 32,
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildSocialContact(packageInfo),
                      ),
                    ],
                    applicationVersion: 'Version \${packageInfo.version}\\nbuild number: \${packageInfo.buildNumber}',
                    applicationLegalese: 'Copyright © 2003-\${Settings.COPYRIGHT_DATE} DeskAngel',
                  );
                }
              },
            ),
          ),
          trailing: IconButton(
            icon: themeModeIcon,
            onPressed: () {
              _showThemeMode();
            },
          ),
        ),
      ],
    );
  }

  Icon get themeModeIcon {
    if (Settings.instance.themeMode == ThemeMode.system.index) {
      return const Icon(Symbols.brightness_auto);
    } else if (Settings.instance.themeMode == ThemeMode.light.index) {
      return const Icon(Symbols.light_mode);
    } else if (Settings.instance.themeMode == ThemeMode.dark.index) {
      return const Icon(Symbols.dark_mode);
    }

    return const Icon(Symbols.brightness_auto);
  }

  Future<void> _showThemeMode() async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      elevation: 10,
      context: this.context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Theme Mode'.tr(), style: Theme.of(context).textTheme.titleMedium),
              ),
              RadioListTile(
                value: ThemeMode.system.index,
                groupValue: Settings.instance.themeMode,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Icon(Symbols.brightness_auto),
                title: Text(Settings.THEME_MODE_NAMES[ThemeMode.system.index].tr()),
                onChanged: (int? index) {
                  Settings.instance.themeMode = index ?? ThemeMode.system.index;
                  themeNotifier.notify();
                },
              ),
              RadioListTile(
                value: ThemeMode.light.index,
                groupValue: Settings.instance.themeMode,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Icon(Symbols.light_mode),
                title: Text(Settings.THEME_MODE_NAMES[ThemeMode.light.index].tr()),
                onChanged: (int? index) {
                  Settings.instance.themeMode = index ?? ThemeMode.light.index;
                  themeNotifier.notify();
                },
              ),
              RadioListTile(
                value: ThemeMode.dark.index,
                groupValue: Settings.instance.themeMode,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Icon(Symbols.dark_mode),
                title: Text(Settings.THEME_MODE_NAMES[ThemeMode.dark.index].tr()),
                onChanged: (int? index) {
                  Settings.instance.themeMode = index ?? ThemeMode.dark.index;
                  themeNotifier.notify();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<IconButton> buildSocialContact(PackageInfo packageInfo) {
    List<IconButton> socialContact = [
      IconButton(
        onPressed: () {
          final _uri = Uri(
            scheme: 'mailto',
            path: 'admin@deskangel.com',
            query: 'subject=[${_projectName.toUpperCase()} v\${packageInfo.version}]',
          );
          launchUrlString(
            _uri.toString(),
            mode: LaunchMode.externalApplication,
          );
        },
        icon: const FaIcon(FontAwesomeIcons.solidEnvelope),
      ),
    ];

    socialContact.addAll([
      IconButton(
        onPressed: () {
          launchUrlString(
            'https://twitter.com/ideskangel',
            mode: LaunchMode.externalApplication,
          );
        },
        icon: const FaIcon(FontAwesomeIcons.xTwitter),
      ),
      IconButton(
        onPressed: () {
          launchUrlString(
            'http://t.me/daremote',
            mode: LaunchMode.externalApplication,
          );
        },
        icon: const FaIcon(FontAwesomeIcons.telegram),
      ),
      IconButton(
        onPressed: () {
          launchUrlString(
            'https://discord.gg/7NzTZWypHs',
            mode: LaunchMode.externalApplication,
          );
        },
        icon: const FaIcon(FontAwesomeIcons.discord),
      ),
    ]);

    return socialContact;
  }
}
''';

bool _createSidePanel(String path) {
  final dir = Directory(p.join(path, 'lib', 'view', 'pages', 'drawer'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final indexFile = File(p.join(dir.path, 'side_panel.dart'));
  if (indexFile.existsSync()) {
    print('\t- ${indexFile.path} seems already exist.');
  } else {
    indexFile.writeAsStringSync(sidePanelContent, flush: true);
  }

  return true;
}

const enJsonContent = '''
{
  "About": "About",
  "Home": "Home",
  "Switch language": "Switch language",
  "WithSystem": "Automatic",
  "Theme Mode": "Theme Mode",
  "Light mode": "Light mode",
  "Dark mode": "Dark mode",
  "Settings": "Settings"
}
''';

const zhJsonContent = '''
{
  "About": "关于",
  "Home": "首页",
  "Switch language": "切换语言",
  "WithSystem": "跟随系统",
  "Theme Mode": "主题模式",
  "Light mode": "浅色模式",
  "Dark mode": "深色模式",
  "Settings": "设置"
}
''';

bool _createi18n(String path) {
  final dir = Directory(p.join(path, 'assets', 'i18n'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final enFile = File(p.join(dir.path, 'en.json'));
  if (enFile.existsSync()) {
    print('\t- ${enFile.path} seems already exist.');
  } else {
    enFile.writeAsStringSync(enJsonContent);
  }

  final zhFile = File(p.join(dir.path, 'zh-CN.json'));
  if (zhFile.existsSync()) {
    print('\t- ${zhFile.path} seems already exist.');
  } else {
    zhFile.writeAsStringSync(zhJsonContent);
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
