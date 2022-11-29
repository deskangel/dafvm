import 'dart:io';

import 'package:dafvm/dafvm.dart' as dafvm;
import 'package:dafvm/dalaunch.dart' as dalaunch;
import 'package:dafvm/dagit.dart' as dagit;
import 'package:dafvm/dalint.dart' as dalint;
import 'package:dafvm/dagradle.dart' as dagradle;
import 'package:dafvm/dakey.dart' as dakey;
import 'package:dafvm/dapackages.dart' as dapackages;
import 'package:dafvm/daproject.dart' as daproject;

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
  } else {
    print('** Succeeded to merge .vscode/settings.json');
  }

  if (!dalaunch.createLaunch(path)) {
    print('- Failed to create .vscode/launch.json');
  } else {
    print('** Succeeded to create .vscode/launch.json');
  }

  dagit.initGitRepository(path);

  if (!dagit.mergeGitIgnore(path)) {
    print('- Failed to merge .gitignore');
  } else {
    print('** Succeeded to merge .gitignore');
  }

  if (!dagit.createGitAttributes(path)) {
    print('- Failed to create .gitattributes. Maybe it is already there.');
  } else {
    print('** Succeeded to create .gitattributes.');
  }

  if (!dalint.appendToAnalysis(path)) {
    print('- Failed to append rules to analysis_options.yaml');
  } else {
    print('** Succeeded to append rules to analysis_options.yaml');
  }

  stdout.write('''

Would you like to to use proxies for gradle?
(You should change the servers and ports to your own afterwards.)
[Y/n] ''');
  String? action = stdin.readLineSync()?.toLowerCase();
  if (action != null && (action.isEmpty || action == 'y' || action == 'yes')) {
    if (!dagradle.appendProxy2Gradle(path)) {
      print('- Failed to append proxy to android/gradle.properties');
    } else {
      print('** Succeeded to append proxy to android/gradle.properties');
    }
  }

  dakey.generateKey(path);
  dakey.initGitCrypt(path);

  if (daproject.prepareProjectFiles(path)) {
    print('** Succeeded to prepare the project files');
  } else {
    print('- Failed to prepare the project files');
  }

  dapackages.addDependencies(path);
}
