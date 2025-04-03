import 'dart:io';
import 'package:dafvm/global.dart';
import 'package:path/path.dart' as p;

bool get needToAddDependencies => promptChoise('''

Would you like to add dependencies? [Y/n] ''');

void addDependencies(String path) {
  stdout.write('\nStart adding dependencies...');

  var result = Process.runSync(
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
    ],
    workingDirectory: path,
  );
  if (result.exitCode == 0) {
    print('');
    print('** Succeeded package dependencies');
  }

  addDevDependencies(path);

  configFlutterIcons(path);
}

void addDevDependencies(String path) {
  var result = Process.runSync(
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
  if (result.exitCode == 0) {
    print('');
    print('** Succeeded package dev dependencies');
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

const assetsLogo = '''
  assets:
    - assets/images/logo.png
''';

bool configFlutterIcons(String path) {
  var file = File(p.join(path, 'pubspec.yaml'));
  if (!file.existsSync()) {
    print('pubspec.yaml file does not exist.');
    return false;
  }

  String content = file.readAsStringSync();
  if (content.contains('flutter_icons:')) {
    print('seems the config has been set already.');
    return false;
  }

  content = content.replaceFirst(RegExp(r'^# For information on the ', multiLine: true), flutterIconsDefinition);
  content = content.replaceFirst(RegExp(r'^  # assets:', multiLine: true), assetsLogo);
  file.writeAsStringSync(content);

  return true;
}
