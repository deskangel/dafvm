import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:path/path.dart' as p;
import 'package:json5/json5.dart';

const settingsJson = '''
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

Future<void> useFlutterSDK(String path) async {
  Process process = await Process.start('fvm', ['use'], workingDirectory: path);
  stdout.addStream(process.stdout);

  await process.stdin.addStream(stdin);
  await process.stdin.close();
}
