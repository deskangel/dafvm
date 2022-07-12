import 'dart:io';

import 'package:dafvm/dafvm.dart' as dafvm;

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

  if (!dafvm.createLaunch(path)) {
    print('- Failed to create .vscode/launch.json');
    exitCode = 2;
  } else {
    print('** Succeeded to create .vscode/launch.json');
  }

  exitCode = 0;
}
