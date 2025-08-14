import 'dart:developer' as dev;
import 'dart:io';

import 'package:dafvm/global.dart';
import 'package:path/path.dart' as p;

const proxyString = '''

systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=8080
''';

bool get needToAppendProxy => promptChoise('''

Would you like to use proxies for gradle?
(You should change the servers and ports to your own afterwards.)
[Y/n] ''');

bool appendProxy2Gradle(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var file = File(p.join(path, 'android', 'gradle.properties'));
  if (!file.existsSync()) {
    print('android/gradle.properties file does not exist.');
    return false;
  }

  String content = file.readAsStringSync();

  if (content.contains('proxyHost')) {
    print('seems that the proxy has been set already.');
    return false;
  }

  content += proxyString;

  file.writeAsStringSync(content);

  return true;
}
