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

  if (dafvm.mergeSettingsJson(arguments[0])) {
    exitCode = 0;
  } else {
    exitCode = 1;
  }
}
