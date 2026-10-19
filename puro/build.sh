puro_version="$(dart bin/puro2.dart version --no-update-check --plain "$@")"
echo "version: $puro_version"
dart compile exe bin/puro2.dart -o bin/puro2 "--define=puro_version=$puro_version"
