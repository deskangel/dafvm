import 'package:test/test.dart';

import '../bin/dafvm.dart';

void main() {
  test('description', () {
    var arguments = ['-ab', '-d'];
    expect(isRequired(arguments, 'a'), true);
    expect(isRequired(arguments, 'b'), true);
    expect(isRequired(arguments, 'c'), false);
    expect(isRequired(arguments, 'd'), true);
  });
}
