import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:path/path.dart' as p;
import 'package:json5/json5.dart';

var settingsJson = '''
{
    "dart.flutterSdkPath": ".fvm/flutter_sdk",
    // Remove .fvm files from search
    "search.exclude": {
        "**/.fvm": true
    },
    // Remove from file watching
    "files.watcherExclude": {
        "**/.fvm": true
    },
    // "java.home": "/usr/local/opt/openjdk",
}
''';

var launchJson = '''
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
        }
    ]
}
''';

bool mergeSettingsJson(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {

    return false;
  }

  // check if .vscode is existed
  var dotvscode = Directory(p.join(path, ".vscode"));
  if (!dotvscode.existsSync()) {
    dotvscode.createSync();
  }

  var jsonfile = File(p.join(dotvscode.path, "settings.json"));
  if (!jsonfile.existsSync()) {
    jsonfile.writeAsStringSync(settingsJson, flush: true);
    return true;
  } else {
    var content = jsonfile.readAsStringSync();
    var json = json5Decode(content) as Map<String, dynamic>;
    json.addAll(json5Decode(settingsJson));
    content = jsonEncode(json);
    jsonfile.writeAsStringSync(content, flush: true);
    return true;
  }
}

bool createLaunch(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var dotvscode = Directory(p.join(path, ".vscode"));
  if (!dotvscode.existsSync()) {
    dotvscode.createSync();
  }

  var jsonfile = File(p.join(dotvscode.path, "launch.json"));
  if (!jsonfile.existsSync()) {
    jsonfile.writeAsStringSync(launchJson, flush: true);
    return true;
  }

  // do not modify the existed launch file
  return false;
}
