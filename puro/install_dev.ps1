# Builds and installs puro2 from source, for development purposes.

& "$PSScriptRoot/build.ps1"
bin/puro2.exe install-puro2 --log-level=4 --promote
