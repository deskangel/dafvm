import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;

const gitignore = '''

# Added by dafvm
!CHANGES.log

# pubspec.lock
# .fvm/flutter_sdk
.build_number
**/debug_info/
macos/Flutter/GeneratedPluginRegistrant.swift
.lh/

# FVM Version Cache
.fvm/
.fvmrc
''';

const gitattr = '''
# Specify filepatterns you want to assign special attributes.

*.jks filter=git-crypt diff=git-crypt
*.pem filter=git-crypt diff=git-crypt
key.properties filter=git-crypt diff=git-crypt
''';

void initGitRepository(String path) {
  var result = Process.runSync('git', ['init'], workingDirectory: path);
  if (result.exitCode == 0) {
    print('** Succeeded init the git repository');
  } else {
    print(result.stderr);
  }
}

bool mergeGitIgnore(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  var file = File(p.join(path, '.gitignore'));
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    if (content.contains('# Added by dafvm')) {
      print('already merged');
      return false;
    }

    file.writeAsStringSync(gitignore, mode: FileMode.append, flush: true);

    return true;
  }

  return false;
}

bool createGitAttributes(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  var file = File(p.join(path, '.gitattributes'));
  if (!file.existsSync()) {
    file.writeAsStringSync(gitattr, flush: true);
    return true;
  }

  // do not modify the existed launch file
  return false;
}
