import 'dart:io';

bool promptChoise(String prompt) {
  stdout.write(prompt);
  String action = stdin.readLineSync()?.toLowerCase() ?? 'y';

  return action == 'yes' || action == 'y';
}
