import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;

const lintRules = '''
  rules:
    constant_identifier_names: false
    unnecessary_this: false
    depend_on_referenced_packages: false
    no_leading_underscores_for_local_identifiers: false
''';

bool appendToAnalysis(String path) {
  print('\nDealing with analysis_options.yaml...');

  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  // check if .vscode is existed
  var file = File(p.join(path, 'analysis_options.yaml'));
  if (!file.existsSync()) {
    print('analysis_options.yaml file does not exist.');
    return false;
  }

  String content = file.readAsStringSync();

  if (content.contains('constant_identifier_names')) {
    print('\t- lint: rules already set');
    return false;
  }

  content = content.replaceFirst(RegExp(r'^  rules:$', multiLine: true), lintRules);

  file.writeAsStringSync(content);

  return true;
}
