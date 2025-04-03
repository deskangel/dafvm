import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:dafvm/global.dart';
import 'package:path/path.dart' as p;
import 'package:json5/json5.dart';

const settingsJson = '''
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": { "**/.fvm": true },
  "files.watcherExclude": { "**/.fvm": true },
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

bool get needToSelectFlutterSDK => promptChoise('''

Would you like to select Flutter SDK? [Y/n] ''');

Future<bool> useFlutterSDK(String path) async {
  var result = Process.runSync('fvm', ['list'], workingDirectory: path);
  if (result.exitCode != 0) {
    print(result.stderr);
    return false;
  }

  // extract the verions from output
  List<String?> versions = [];
  String content = result.stdout;
  var regexp = RegExp(r'(\d+\.\d+\.\d+)');
  var match = regexp.allMatches(content);
  for (var element in match) {
    versions.add(element.group(0));
  }

  // out put the version list
  print('Set Flutter SDK version... ...');
  for (int i = 0; i < versions.length; i++) {
    var version = versions[i];
    print('[${i + 1}] $version');
  }

  do {
    stdout.write('\nSelect a version: ');

    int? seletedIndex = int.tryParse(stdin.readLineSync() ?? '1');
    if (seletedIndex == null || seletedIndex < 1 || seletedIndex > versions.length) {
      continue;
    }

    String version = versions[seletedIndex - 1] ?? '';
    if (version.isEmpty) {
      continue;
    }

    final process = await Process.start('fvm', ['use', '-f', version], workingDirectory: path);
    process.stdout.transform(utf8.decoder).listen(print);
    process.stderr.transform(utf8.decoder).listen(print);
    if (await process.exitCode == 0) {
      return true;
    } else {
      return false;
    }
  } while (true);
}
