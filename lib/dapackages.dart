import 'dart:convert';
import 'dart:io';
import 'package:dafvm/global.dart';
import 'package:path/path.dart' as p;

bool get needToAddDependencies => promptChoise('''

Would you like to add package dependencies? [Y/n] ''');

Future<void> addDependencies(String path) async {
  print('\nDealing with package dependencies...');

  final process = await Process.start(
    'fvm',
    [
      'flutter',
      'pub',
      'add',
      'shared_preferences',
      'provider',
      'font_awesome_flutter',
      'sqflite',
      'easy_localization',
      'path_provider',
      'material_symbols_icons',
      'url_launcher',
      'package_info_plus',
      'device_info_plus',
      'dynamic_color',
      'collection',
    ],
    workingDirectory: path,
  );
  process.stdout.transform(utf8.decoder).listen(print);
  process.stderr.transform(utf8.decoder).listen(print);

  if (await process.exitCode == 0) {
    print('** Succeeded to add dependencies');
  } else {
    print('- Failed to add dependencies');
  }

  await _addDevDependencies(path);

  if (_configFlutterIcons(path)) {
    print('** Succeeded to config flutter icons');
  } else {
    print('- Failed to config flutter icons');
  }
}

Future<void> _addDevDependencies(String path) async {
  print('\nDealing with dev dependencies...');

  final process = await Process.start(
    'fvm',
    [
      'flutter',
      'pub',
      'add',
      '-d',
      'flutter_launcher_icons',
    ],
    workingDirectory: path,
  );

  process.stdout.transform(utf8.decoder).listen(print);
  process.stderr.transform(utf8.decoder).listen(print);

  if (await process.exitCode == 0) {
    print('** Succeeded to add dev dependencies');
  } else {
    print('- Failed to add dev dependencies');
  }
}

const flutterIconsDefinition = '''
flutter_icons:
  image_path: 'assets/images/logo.png'
  android: "ic_launcher"
  ios: true
  min_sdk_android: 21
  remove_alpha_ios: true

# For information on the ''';

const assets = '''
  assets:
    - assets/images/
    - assets/i18n/
''';

bool _configFlutterIcons(String path) {
  print('\nDealing with flutter icons...');

  var file = File(p.join(path, 'pubspec.yaml'));
  if (!file.existsSync()) {
    print('\t- pubspec.yaml file does not exist.');
    return false;
  }

  String content = file.readAsStringSync();
  if (content.contains('flutter_icons:')) {
    print('\t- seems the config has been set already.');
    return false;
  }

  content = content.replaceFirst(RegExp(r'^# For information on the ', multiLine: true), flutterIconsDefinition);
  content = content.replaceFirst(RegExp(r'^  # assets:', multiLine: true), assets);
  file.writeAsStringSync(content);

  return true;
}
