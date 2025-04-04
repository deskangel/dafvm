import 'package:dafvm/dabuild.dart' as dabuild;
import 'package:dafvm/dafvm.dart' as dafvm;
import 'package:dafvm/dagit.dart' as dagit;
import 'package:dafvm/dagradle.dart' as dagradle;
import 'package:dafvm/dakey.dart' as dakey;
import 'package:dafvm/dalaunch.dart' as dalaunch;
import 'package:dafvm/dalint.dart' as dalint;
import 'package:dafvm/dapackages.dart' as dapackages;
import 'package:dafvm/daproject.dart' as daproject;

bool isRequired(List<String> arguments, String flag) {
  if (arguments.isEmpty) {
    return true;
  }

  for (var arg in arguments) {
    if (arg.startsWith('-') && arg.contains(flag)) {
      return true;
    }
  }

  return false;
}

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('''
Usage: dafvm path [-p]
path    Path to the project root
        An empty option means all features are required

[Options]:
-s      Merge .vscode/settings.json
-l      Create .vscode/launch.json
-f      Set Flutter SDK
-g      Set up git
-d      Add package dependencies
-a      Add analysis options
-b      Add build script
-k      Add key files, init git-crypt and config the build gradle file
-j      Create project files
-p      Set up proxy in android/gradle.properties
''');
    return;
  }

  var path = arguments[0];

  final remainArgs = arguments.sublist(1);

  if (isRequired(remainArgs, '-s')) {
    if (!dafvm.mergeSettingsJson(path)) {
      print('- Failed to merge .vscode/settings.json');
    } else {
      print('** Succeeded to merge .vscode/settings.json');
    }
  }

  if (isRequired(remainArgs, '-f') && dafvm.needToSelectFlutterSDK) {
    if (!await dafvm.useFlutterSDK(path)) {
      print('- Failed to set Flutter SDK version');
    } else {
      print('** Succeeded to set Flutter SDK version');
    }
  }

  if (isRequired(remainArgs, '-l')) {
    if (!dalaunch.createLaunch(path)) {
      print('- Failed to create .vscode/launch.json');
    } else {
      print('** Succeeded to create .vscode/launch.json');
    }
  }

  if (isRequired(remainArgs, '-g')) {
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
  }

  if (isRequired(remainArgs, '-a')) {
    if (!dalint.appendToAnalysis(path)) {
      print('- Failed to append rules to analysis_options.yaml');
    } else {
      print('** Succeeded to append rules to analysis_options.yaml');
    }
  }

  if (isRequired(remainArgs, '-b')) {
    if (!dabuild.createBuildScript(path)) {
      print('- Failed to create release_build.sh');
    } else {
      print('** Succeeded to create release_build.sh');
    }
  }

  if (isRequired(arguments, '-p') && dagradle.needToAppendProxy) {
    if (!dagradle.appendProxy2Gradle(path)) {
      print('- Failed to append proxy to android/gradle.properties');
    } else {
      print('** Succeeded to append proxy to android/gradle.properties');
    }
  }

  if (isRequired(remainArgs, '-k')) {
    dakey.generateKey(path);
    dakey.initGitCrypt(path);

    if (!dakey.configSignKeyInGradle(path)) {
      print('- Failed to config the signing in android/app/build.gradle or android/app/build.gradle.kts file');
    } else {
      print('** Succeeded to config the signing in android/app/build.gradle or android/app/build.gradle.kts file');
    }
  }

  if (isRequired(remainArgs, '-j')) {
    if (daproject.prepareProjectFiles(path)) {
      print('** Succeeded to prepare the project files');
    } else {
      print('- Failed to prepare the project files');
    }
  }

  if (isRequired(arguments, '-d') && dapackages.needToAddDependencies) {
    dapackages.addDependencies(path);
  }
}
