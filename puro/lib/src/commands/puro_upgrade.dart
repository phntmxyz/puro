import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../command.dart';
import '../config.dart';
import '../downloader.dart';
import '../http.dart';
import '../process.dart';
import '../terminal.dart';
import '../version.dart';

class PuroUpgradeCommand extends PuroCommand {
  PuroUpgradeCommand() {
    argParser.addFlag(
      'force',
      hide: true,
      help:
          'Installs a new puro executable even if it wont replace an existing one',
    );
  }

  @override
  final name = 'upgrade-puro';

  @override
  List<String> get aliases => ['update-puro'];

  @override
  String? get argumentUsage => '[version]';

  @override
  final description = 'Upgrades the puro tool to a new version';

  @override
  bool get allowUpdateCheck => false;

  @override
  Future<CommandResult> run() async {
    final force = argResults!['force'] as bool;
    final http = scope.read(clientProvider);
    final config = PuroConfig.of(scope);
    final currentVersion = await getPuroVersion(scope: scope);
    final repository = await getPuroDevelopmentRepository(scope: scope);
    if ((currentVersion.build.isNotEmpty || repository != null) && !force) {
      return BasicMessageResult(
        success: false,
        message: 'Upgrading development versions is not supported',
      );
    }

    File? currentExecutable =
        config.fileSystem.file(Platform.resolvedExecutable);
    if (currentExecutable.path != config.puroExecutableFile.path) {
      if (force) {
        currentExecutable = null;
      } else {
        return BasicMessageResult(
          success: false,
          message: 'Upgrading standalone executables is not supported',
        );
      }
    }

    var targetVersionString = unwrapSingleOptionalArgument();
    final Version targetVersion;
    if (targetVersionString == null) {
      final latestVersionResponse =
          await http.get(config.puroBuildsUrl.append(path: 'latest'));
      HttpException.ensureSuccess(latestVersionResponse);
      targetVersionString = latestVersionResponse.body.trim();
      targetVersion = Version.parse(targetVersionString);
      if (currentVersion == targetVersion && !force) {
        return BasicMessageResult(
          success: true,
          message: 'Puro is up to date with $targetVersion',
          type: CompletionType.indeterminate,
        );
      } else if (currentVersion > targetVersion && !force) {
        return BasicMessageResult(
          success: true,
          message:
              'Puro is a newer version $currentVersion than the available $targetVersion',
          type: CompletionType.indeterminate,
        );
      }
    } else {
      targetVersion = Version.parse(targetVersionString);
      if (currentVersion == targetVersion && !force) {
        return BasicMessageResult(
          success: true,
          message: 'Puro is already the desired version $targetVersion',
          type: CompletionType.indeterminate,
        );
      }
    }
    final buildTarget = config.buildTarget;
    final tempFile = config.puroExecutableTempFile;
    await downloadFile(
      scope: scope,
      url: config.puroBuildsUrl.append(
        path: '$targetVersion/'
            '${buildTarget.name}/'
            '${buildTarget.executableName}',
      ),
      file: tempFile,
      description: 'Downloading puro $targetVersion',
    );
    if (!Platform.isWindows) {
      await runProcess(scope, 'chmod', ['+x', '--', tempFile.path]);
    }
    currentExecutable?.renameSync(config.puroExecutableOldFile.path);
    tempFile.renameSync(config.puroExecutableFile.path);

    final terminal = Terminal.of(scope);
    terminal.flushStatus();
    final installProcess = await startProcess(
      scope,
      config.puroExecutableFile.path,
      [
        if (terminal.enableColor) '--color',
        if (terminal.enableStatus) '--progress',
        'install-puro',
      ],
    );
    final stdoutFuture =
        installProcess.stdout.listen(stdout.add).asFuture<void>();
    await installProcess.stderr.listen(stderr.add).asFuture<void>();
    await stdoutFuture;
    await runner.exitPuro(await installProcess.exitCode);
  }
}
