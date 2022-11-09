import 'dart:io';
import 'dart:developer' as dev;
import 'package:path/path.dart' as p;

void initGitCrypt(String path) {
  stdout.write('''
Would you like to init the git-crypt? [Y/n] ''');
  String? action = stdin.readLineSync()?.toLowerCase();
  if (action != null && (action.isEmpty || action == 'y' || action == 'yes')) {
    var result = Process.runSync('git-crypt', ['init'], workingDirectory: path);
    if (result.exitCode == 0) {
      print('** Succeeded init the git-crypt');
    } else {
      print(result.stderr);
    }
  }
}

void generateKey(String path) {
  path = '/Users/wxue/Projects/flutter/tmp/dafvmtest';

  stdout.write('''
  Would you like to create a keystore file with the following information?
keytool -genkeypair -dname "CN=iDeskAngel,OU=R&D,O=DeskAngel Studio,L=Hangzhou,ST=ZheJiang,C=CN" -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
[Y/n] ''');

  String? action = stdin.readLineSync()?.toLowerCase();

  if (action == null) {
    return;
  }

  if (action.isEmpty || action == 'y' || action == 'yes') {
    stdout.write('keystore password:');

    var echoMode = stdin.echoMode;
    stdin.echoMode = false;
    String? storePass = stdin.readLineSync();
    stdin.echoMode = echoMode;

    var result = Process.runSync(
        'keytool',
        [
          '-genkeypair',
          '-storepass',
          '$storePass',
          '-dname',
          '"CN=iDeskAngel,OU=R&D,O=DeskAngel Studio,L=Hangzhou,ST=ZheJiang,C=CN"',
          '-v',
          '-keystore',
          'android/key.jks',
          '-keyalg',
          'RSA',
          '-keysize',
          '2048',
          '-validity',
          '10000',
          '-alias',
          'key',
        ],
        workingDirectory: path);
    if (result.exitCode == 0) {
      print('** Succeeded generated the keystore file');

      if (!configSignKeyProperties(path, storePass)) {
        print('- Failed to config the android/key.properties file');
      } else {
        print('** Succeeded to config the android/key.properties file');
      }

      if (!configSignKeyInGradle(path)) {
        print('- Failed to config the signing in android/app/build.gradle file');
      } else {
        print('** Succeeded to config the signing in android/app/build.gradle file');
      }
    } else {
      print('${result.stderr}\nexit code: ${result.exitCode}');
    }
  } else {
    print('''
    You can use the following command to generate the keystore file manually later:
keytool -genkeypair -dname "CN=iDeskAngel,OU=R&D,O=DeskAngel Studio,L=Hangzhou,ST=ZheJiang,C=CN" -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
''');
  }
}

bool configSignKeyProperties(String path, String? storePass) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var file = File(p.join(path, 'android', 'key.properties'));

  String keyProperties = '''
storePassword=${storePass ?? ''}
keyPassword=${storePass ?? ''}
keyAlias=key
storeFile=../key.jks
''';

  if (file.existsSync()) {
    String content = file.readAsStringSync();

    if (content.contains('storePassword')) {
      print('seems the config has been set');
      return false;
    }

    content += keyProperties;
    file.writeAsStringSync(content);
  } else {
    file.writeAsStringSync(keyProperties);
  }

  return true;
}

const keystoreDefinition = '''
def keystorePropertiesFile = rootProject.file('key.properties')
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
''';

const signingConfig = '''
            signingConfig signingConfigs.release
            minifyEnabled true
''';

bool configSignKeyInGradle(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var file = File(p.join(path, 'android', 'app', 'build.gradle'));
  if (!file.existsSync()) {
    print('android/gradle.properties file does not exist.');
    return false;
  }

  String content = file.readAsStringSync();
  if (content.contains('signingConfigs.release')) {
    print('seems the config has been set already.');
    return false;
  }

  content = content.replaceFirst(RegExp(r'^android {$', multiLine: true), keystoreDefinition);
  content = content.replaceFirst(
    RegExp(r'^            signingConfig signingConfigs.debug$', multiLine: true),
    signingConfig,
  );

  file.writeAsStringSync(content);

  return true;
}
