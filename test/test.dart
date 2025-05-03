import 'package:dafvm/global.dart';
import 'package:test/test.dart';

import '../bin/dafvm.dart';

void main() {
  test('parse arguments', () {
    var arguments = ['./', '-ab', '-d', '-h'];
    expect(isRequired(arguments, 'h'), true);
    expect(isRequired(arguments, 'a'), true);
    expect(isRequired(arguments, 'b'), true);
    expect(isRequired(arguments, 'c'), false);
    expect(isRequired(arguments, 'd'), true);
  });

  test('parse arguments with prefix -', () {
    var arguments = ['./', '-ab', '-d', '-h'];
    expect(isRequired(arguments, '-h'), true);
    expect(isRequired(arguments, '-a'), true);
    expect(isRequired(arguments, '-b'), true);
    expect(isRequired(arguments, '-c'), false);
    expect(isRequired(arguments, '-d'), true);
  });

  test('without arguments', () {
    List<String> arguments = [];
    expect(isRequired(arguments, '-h'), true);
    expect(isRequired(arguments, '-a'), false);
    expect(isRequired(arguments, '-b'), false);
    expect(isRequired(arguments, '-c'), false);
    expect(isRequired(arguments, '-d'), false);
  });

  test('get project name from yaml', () {
    projectRootPath = '.';
    expect(projectName, 'Dafvm');
  });
}
