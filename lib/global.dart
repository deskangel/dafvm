import 'dart:io';
import 'package:path/path.dart' as p;

bool promptChoise(String prompt) {
  stdout.write(prompt);
  String action = stdin.readLineSync()?.toLowerCase() ?? 'y';

  return action.isEmpty || action == 'yes' || action == 'y';
}

String? projectRootPath;
String? _projectName;
String get projectName {
  assert(projectRootPath != null, 'projectRootPath is not set');

  return _projectName ??= _getProjectName(projectRootPath!);
}

String _getProjectName(String path) {
  final file = File(p.join(path, 'pubspec.yaml'));

  String content = file.readAsStringSync();
  final lines = content.split('\n');
  for (final line in lines) {
    if (line.startsWith('name:')) {
      var name = line.split(':')[1].trim();
      // convert to camelCase
      return name[0].toUpperCase() + name.substring(1);
    }
  }

  return 'Project';
}
