import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;

const launchJson = '''
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter",
            "request": "launch",
            "type": "dart"
        },
        {
          "name": "Android Attach",
          "request": "attach",
          "type": "android",
          "appSrcRoot": "\${workspaceRoot}/android/app/src/main",
          "adbPort": 5037,
          "processId": "\${command:PickAndroidProcess}"
        }
    ]
}
''';

bool createLaunch(String path) {
  print('\nDealing with pubspec.yaml...');

  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var dotvscode = Directory(p.join(path, '.vscode'));
  if (!dotvscode.existsSync()) {
    dotvscode.createSync();
  }

  var jsonfile = File(p.join(dotvscode.path, 'launch.json'));
  print(jsonfile.path);
  if (!jsonfile.existsSync()) {
    jsonfile.writeAsStringSync(launchJson, flush: true);
    return true;
  } else {
    print('\t- launch.json already exist');
  }

  // do not modify the existed launch file
  return false;
}
