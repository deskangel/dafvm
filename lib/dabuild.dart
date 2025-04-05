import 'dart:io';
import 'dart:developer' as dev;
import 'package:dafvm/global.dart';
import 'package:path/path.dart' as p;

final String buildScript = '''
#!/bin/bash

BUILD_NUMBER=\$(cat .build_number)
BUILD_NUMBER=\$((BUILD_NUMBER + 1))

APP_NAME=$projectName

YEAR_NUMBER=\$(date +"%Y")

###################################################################

OPT_APP_FORMAT=""
OPT_DEPLOYMENT=""
BUILD_RESULT=0

for optname in "\$@"; do
    case \$optname in
    app)
        OPT_APP_FORMAT="app"
        ;;
    apk)
        OPT_APP_FORMAT="apk"
        ;;
    macos)
        OPT_APP_FORMAT="macos"
        ;;
    linux)
        OPT_APP_FORMAT="linux"
        ;;
    -d)
        OPT_DEPLOYMENT="-d"
        ;;
    -h)
        echo "usage: \$0 [apk | app | macos | linux] [-d]"
        exit 0
        ;;
    esac
done

clrecho() {
    printf "\\e[38;5;196m\$1\\e[0m\n"
}

sed_replace_regex() {
    if [[ \$(uname) == "Darwin" ]]; then
        sed -Ei '' "\$@"
    else
        sed -Ei "\$@"
    fi
}

sed_replace() {
    if [[ \$(uname) == "Darwin" ]]; then
        sed -i '' "\$@"
    else
        sed -i "\$@"
    fi
}

###################################################################
if [[ "\$OPT_APP_FORMAT" == "app" ]]; then
    set -x
    sed_replace_regex "s/version: (.*)\\+([0-9]+\$)/version: \\1\\+\$BUILD_NUMBER/g" pubspec.yaml
    sed_replace_regex "s/static const int COPYRIGHT_DATE = ([0-9]+);\$/static const int COPYRIGHT_DATE = \$YEAR_NUMBER;/g" lib/controller/settings.dart

    fvm flutter build appbundle --obfuscate --release --split-debug-info=debug_info/\$BUILD_NUMBER --build-number \$BUILD_NUMBER
    BUILD_RESULT=\$?

    set +x

    # Update the build number
    if [[ \$BUILD_RESULT == 0 ]]; then
        echo \$BUILD_NUMBER >.build_number

        open "build/app/outputs/bundle/release/"
    else
        clrecho "Failed to build the \$OPT_APP_FORMAT"
    fi
elif [[ "\$OPT_APP_FORMAT" == "apk" ]]; then
    set -x
    sed_replace_regex "s/static const int COPYRIGHT_DATE = ([0-9]+);\$/static const int COPYRIGHT_DATE = \$YEAR_NUMBER;/g" lib/controller/settings.dart

    fvm flutter build apk --obfuscate --release --split-per-abi --split-debug-info=debug_info/\$BUILD_NUMBER --build-number \$BUILD_NUMBER
    BUILD_RESULT=\$?

    set +x

    # Update the build number
    if [[ \$BUILD_RESULT == 0 ]]; then
        echo \$BUILD_NUMBER >.build_number
    else
        clrecho "Failed to build the \$OPT_APP_FORMAT"
    fi
elif [[ "\$OPT_APP_FORMAT" == "macos" ]]; then
    set -x
    # sed_replace_regex "s/version: (.*)\\+([0-9]+\$)/version: \\1\\+\$BUILD_NUMBER/g" pubspec.yaml
    sed_replace_regex "s/static const int COPYRIGHT_DATE = ([0-9]+);\$/static const int COPYRIGHT_DATE = \$YEAR_NUMBER;/g" lib/controller/settings.dart

    fvm flutter clean
    fvm flutter build macos --obfuscate --release --split-debug-info=debug_info/\$BUILD_NUMBER --build-number \$BUILD_NUMBER
    BUILD_RESULT=\$?

    set +x

    # Update the build number
    if [[ \$BUILD_RESULT == 0 ]]; then
        echo \$BUILD_NUMBER >.build_number
    else
        clrecho "Failed to build the \$OPT_APP_FORMAT"
    fi
elif [[ "\$OPT_APP_FORMAT" == "linux" ]]; then
    set -x
    # sed -Ei "s/version: (.*)\\+([0-9]+\$)/version: \\1\\+\$BUILD_NUMBER/g" pubspec.yaml
    sed_replace_regex "s/static const int COPYRIGHT_DATE = ([0-9]+);\$/static const int COPYRIGHT_DATE = \$YEAR_NUMBER;/g" lib/controller/settings.dart

    fvm flutter clean
    fvm flutter build linux --obfuscate --release --split-debug-info=debug_info/\$BUILD_NUMBER --build-number \$BUILD_NUMBER
    BUILD_RESULT=\$?

    set +x

    # Update the build number
    if [[ \$BUILD_RESULT == 0 ]]; then
        VERSION=\$(grep -oP 'version:\\s*\\K\\d+(\\.\\d+){2}' pubspec.yaml)
        sed_replace_regex "s/Version=.*\$/Version=\$VERSION/g" linux/assets/${projectName.toLowerCase()}.desktop
        # update the version in ${projectName.toLowerCase()}.desktop
        echo \$BUILD_NUMBER >.build_number
    else
        clrecho "Failed to build the \$OPT_APP_FORMAT"
    fi
fi

if [[ \$BUILD_RESULT == 0 && \$OPT_DEPLOYMENT == "-d" ]]; then
    if [[ "\$OPT_APP_FORMAT" == "macos" ]]; then
        echo "deploy to ~/Applications"
        rm -rf "~/Applications/\$APP_NAME.app"
        cp -r "build/macos/Build/Products/Release/\$APP_NAME.app" ~/Applications/
    elif [[ "\$OPT_APP_FORMAT" == "linux" ]]; then
        echo "deploy to /opt/\$APP_NAME"
        sudo mv "/opt/\$APP_NAME" "/opt/\$APP_NAME.bk"

        cp -f linux/assets/${projectName.toLowerCase()}.png ~/.local/share/icons/${projectName.toLowerCase()}.png
        sudo cp -f linux/assets/${projectName.toLowerCase()}.desktop /usr/share/applications/${projectName.toLowerCase()}.desktop
        sudo cp -r build/linux/x64/release/bundle "/opt/\$APP_NAME"
        sudo rm -rf "/opt/\$APP_NAME.bk"
    else
        scp2p30p build/app/outputs/apk/release/app-arm64-v8a-release.apk /root/download/
    fi
fi

''';

bool createBuildScript(String path) {
  print('\nDealing with release_build.sh...');

  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  final file = File(p.join(path, 'release_build.sh'));
  if (file.existsSync()) {
    print('\t- ${file.path} seems already exist.');
    return false;
  }

  file.writeAsStringSync(buildScript, flush: true);

  _createBuildNumberFile(path);
  return true;
}

bool _createBuildNumberFile(String path) {
  var dir = Directory(path);
  dev.log(dir.path);
  if (!dir.existsSync()) {
    print('path not exists');
    return false;
  }

  final file = File(p.join(path, '.build_number'));
  if (file.existsSync()) {
    print('\t- ${file.path} seems already exist.');
    return false;
  }

  file.writeAsStringSync('1', flush: true);
  return true;
}
