import 'dart:io';
import 'dart:developer' as dev;
import 'package:path/path.dart' as p;

int initGitCrypt(String path) {
  print('\nDealing with git-crypt...');

  final keyFile = File(p.join(path, '.git', 'git-crypt', 'keys', 'default'));
  if (keyFile.existsSync()) {
    print('\t- git-crypt already initialized');
    return 0;
  }

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

    return result.exitCode;
  }

  return 0;
}

void generateKey(String path) {
  stdout.write('''

Would you like to create a keystore file with the following information?
keytool -genkeypair -dname "cn=iDeskAngel,ou=R&D,o=DeskAngel Studio,l=Hangzhou,st=ZheJiang,c=CN" -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
[Y/n] ''');

  String? action = stdin.readLineSync()?.toLowerCase();

  if (action == null) {
    return;
  }

  if (action.isEmpty || action == 'y' || action == 'yes') {
    var echoMode = stdin.echoMode;
    stdin.echoMode = false;
    String storePass;
    do {
      stdout.write('keystore password:');
      storePass = stdin.readLineSync() ?? '';
      if (storePass.length < 6) {
        stdout.write('\nPassword must be at least 6 characters.\n');
      }
    } while (storePass.length < 6);
    stdin.echoMode = echoMode;

    print('\n');

    var result = Process.runSync(
      'keytool',
      [
        '-genkeypair',
        '-v',
        '-storepass',
        storePass,
        '-dname',
        'cn=iDeskAngel,ou=R&D,o=DeskAngel Studio,l=Hangzhou,st=ZheJiang,c=CN',
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
      // runInShell: true,
      workingDirectory: path,
    );

    if (result.exitCode == 0) {
      print('');
      print('** Succeeded generated the keystore file');

      if (!configSignKeyProperties(path, storePass)) {
        print('- Failed to config the android/key.properties file');
      } else {
        print('** Succeeded to config the android/key.properties file');
      }
    } else {
      print('${result.stderr}\n${result.stdout}\nexit code: ${result.exitCode}');
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

bool configSignKeyInGradle(String path) {
  print('\nDealing with signing keys in android/app/build.gradle[.kts] ...');

  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var file = File(p.join(path, 'android', 'app', 'build.gradle'));
  if (file.existsSync()) {
    return _configSignKeyInGradleGroovy(file);
  }

  file = File(p.join(path, 'android', 'app', 'build.gradle.kts'));
  if (file.existsSync()) {
    return _configSignKeyInGradleKts(file);
  }

  print('\t- none of android/app/build.gradle[.kts] does not exist.');
  return false;
}

bool _configSignKeyInGradleGroovy(File file) {
  String content = file.readAsStringSync();
  if (content.contains('signingConfigs.release')) {
    print('\t- seems the config has been set already.');
    return false;
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

  const signingConfigs = '''
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
  ''';

  content = content.replaceFirst(RegExp(r'^android {$', multiLine: true), keystoreDefinition);
  content = content.replaceFirst(
    RegExp(r'^\s+signingConfig signingConfigs.debug$', multiLine: true),
    signingConfig,
  );
  content = content.replaceFirst(RegExp(r'^\s+buildTypes {', multiLine: true), signingConfigs);

  file.writeAsStringSync(content);

  return true;
}

bool _configSignKeyInGradleKts(File file) {
  String content = file.readAsStringSync();
  if (content.contains('signingConfigs.getByName("release")')) {
    print('seems the config has been set already.');
    return false;
  }

  const import = '''
import java.util.Properties
import java.io.FileInputStream

''';

  const keystoreDefinition = '''
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { inputStream ->
        keystoreProperties.load(inputStream)
    }
}

android {''';

  const signingConfigs = '''
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            signingConfig = signingConfigs.getByName("debug")
        }
''';

  const releaseSigningConfig = '''
signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true''';

  content = import + content;

  content = content.replaceFirst('flutter.compileSdkVersion', '35');
  content = content.replaceFirst('ndkVersion = flutter.ndkVersion', '// ndkVersion = flutter.ndkVersion');
  content = content.replaceFirst('flutter.minSdkVersion', '24');
  content = content.replaceFirst('flutter.targetSdkVersion', '35');
  content = content.replaceFirst('signingConfig = signingConfigs.getByName("debug")', releaseSigningConfig);

  content = content.replaceFirst(RegExp(r'^android {$', multiLine: true), keystoreDefinition);
  content = content.replaceFirst(RegExp(r'^ +buildTypes {$', multiLine: true), signingConfigs);

  file.writeAsStringSync(content);

  return true;
}
