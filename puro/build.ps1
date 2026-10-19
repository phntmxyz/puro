$puro_version = dart bin/puro2.dart version --no-update-check --plain @args
Write-Output "Version: $puro_version"
dart compile exe bin/puro2.dart -o bin/puro2.exe --define=puro_version=$puro_version
