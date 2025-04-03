import 'package:dafvm/dabuild.dart' as dabuild;
import 'package:dafvm/dafvm.dart' as dafvm;
import 'package:dafvm/dagit.dart' as dagit;
import 'package:dafvm/dagradle.dart' as dagradle;
import 'package:dafvm/dakey.dart' as dakey;
import 'package:dafvm/dalaunch.dart' as dalaunch;
import 'package:dafvm/dalint.dart' as dalint;
import 'package:dafvm/dapackages.dart' as dapackages;
import 'package:dafvm/daproject.dart' as daproject;

void main(List<String> arguments) async {
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

  if (dafvm.needToSelectFlutterSDK) {
    if (!await dafvm.useFlutterSDK(path)) {
      print('- Failed to set Flutter SDK version');
    } else {
      print('** Succeeded to set Flutter SDK version');
    }
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

  if (!dabuild.createBuildScript(path)) {
    print('- Failed to create release_build.sh');
  } else {
    print('** Succeeded to create release_build.sh');
  }

  if (dagradle.needToAppendProxy) {
    if (!dagradle.appendProxy2Gradle(path)) {
      print('- Failed to append proxy to android/gradle.properties');
    } else {
      print('** Succeeded to append proxy to android/gradle.properties');
    }
  }

  dakey.generateKey(path);
  dakey.initGitCrypt(path);

  if (!dakey.configSignKeyInGradle(path)) {
    print('- Failed to config the signing in android/app/build.gradle or android/app/build.gradle.kts file');
  } else {
    print('** Succeeded to config the signing in android/app/build.gradle or android/app/build.gradle.kts file');
  }

  if (daproject.prepareProjectFiles(path)) {
    print('** Succeeded to prepare the project files');
  } else {
    print('- Failed to prepare the project files');
  }

  if (dapackages.needToAddDependencies) {
    dapackages.addDependencies(path);
  }
}
