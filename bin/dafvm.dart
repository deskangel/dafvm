import 'dart:io';

import 'package:dafvm/dafvm.dart' as dafvm;
import 'package:dafvm/dalaunch.dart' as dalaunch;
import 'package:dafvm/dagit.dart' as dagit;

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('''
Usage: dafvm path
path    Path to the project root
''');
    return;
  }

  var path = arguments[0];
  if (!dafvm.mergeSettingsJson(path)) {
    print('- Failed to merge .vscode/settings.json');
    exitCode = 1;
  } else {
    print('** Succeeded to merge .vscode/settings.json');
  }

  if (!dalaunch.createLaunch(path)) {
    print('- Failed to create .vscode/launch.json');
    exitCode = 2;
  } else {
    print('** Succeeded to create .vscode/launch.json');
  }


  if (!dagit.mergeGitIgnore(path)) {
    print('- Failed to merge .gitignore');
    exitCode = 2;
  } else {
    print('** Succeeded to merge .gitignore');
  }

  if (!dagit.createGitAttributes(path)) {
    print('- Failed to create .gitattributes');
    exitCode = 2;
  } else {
    print('** Succeeded to create .gitattributes.');
  }

  print('''
** NEXT STEPS:
  1. run `git-crypt init`
  2. run `keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key`
  3. create file 'android/key.properties' and add
    ```
      storePassword=
      keyPassword=
      keyAlias=key
      storeFile=../key.jks
    ```
  4. add proxies to 'android/gradle.properties':
    ```
      systemProp.http.proxyHost=127.0.0.1
      systemProp.http.proxyPort=8088
      systemProp.https.proxyHost=127.0.0.1
      systemProp.https.proxyPort=8088
    ```
  ''');

  exitCode = 0;
}
