import 'dart:async';

import 'package:clock/clock.dart';
import 'package:neoansi/neoansi.dart';

import 'provider.dart';

enum LogLevel {
  wtf,
  error,
  warning,
  verbose,
  debug;

  bool operator >(LogLevel other) {
    return index > other.index;
  }

  bool operator <(LogLevel other) {
    return index < other.index;
  }

  bool operator >=(LogLevel other) {
    return index >= other.index;
  }

  bool operator <=(LogLevel other) {
    return index <= other.index;
  }
}

class LogEntry {
  LogEntry(this.timestamp, this.level, this.message);

  final DateTime timestamp;
  final LogLevel level;
  final String message;
}

class PuroLogger {
  PuroLogger({
    this.level,
    required this.onEvent,
  });

  final LogLevel? level;
  final void Function(LogEntry entry) onEvent;

  void add(LogEntry event) => onEvent(event);

  void d(String message) {
    if (level == null || level! < LogLevel.debug) return;
    add(LogEntry(DateTime.now(), LogLevel.debug, message));
  }

  void v(String message) {
    if (level == null || level! < LogLevel.verbose) return;
    add(LogEntry(DateTime.now(), LogLevel.verbose, message));
  }

  void w(String message) {
    if (level == null || level! < LogLevel.warning) return;
    add(LogEntry(DateTime.now(), LogLevel.warning, message));
  }

  void e(String message) {
    if (level == null || level! < LogLevel.error) return;
    add(LogEntry(DateTime.now(), LogLevel.error, message));
  }

  void wtf(String message) {
    if (level == null || level! < LogLevel.wtf) return;
    add(LogEntry(DateTime.now(), LogLevel.wtf, message));
  }

  static final provider = Provider<PuroLogger>.late();
  static PuroLogger of(Scope scope) => scope.read(provider);
}

class PuroPrinter extends Sink<LogEntry> {
  PuroPrinter({
    required this.sink,
    required this.enableColor,
  });

  final StringSink sink;
  final bool enableColor;

  static const levelPrefixes = {
    LogLevel.wtf: '[WTF]',
    LogLevel.error: '[E]',
    LogLevel.warning: '[W]',
    LogLevel.verbose: '[V]',
    LogLevel.debug: '[D]',
  };

  static const levelColors = {
    LogLevel.wtf: Ansi8BitColor.pink1,
    LogLevel.error: Ansi8BitColor.red,
    LogLevel.warning: Ansi8BitColor.orange1,
    LogLevel.verbose: Ansi8BitColor.yellow,
    LogLevel.debug: Ansi8BitColor.grey35,
  };

  @override
  void add(LogEntry data) {
    var label = levelPrefixes[data.level]!;
    final labelLength = label.length;
    if (enableColor) {
      final buffer = StringBuffer();
      AnsiWriter.from(buffer)
        ..setBold()
        ..setForegroundColor8(levelColors[data.level]!)
        ..write(label)
        ..resetStyles();
      label = '$buffer';
    }
    final lines = '$label ${data.message}'.trim().split('\n');
    sink.writeln(
      [
        lines.first,
        for (final line in lines.skip(1)) '${' ' * labelLength} $line',
      ].join('\n'),
    );
  }

  @override
  void close() {}
}

FutureOr<T?> runOptional<T>(
  Scope scope,
  String action,
  Future<T> fn(), {
  LogLevel level = LogLevel.error,
  LogLevel? exceptionLevel,
}) async {
  final log = PuroLogger.of(scope);
  log.v(action.substring(0, 1).toUpperCase() + action.substring(1) + '...');
  try {
    return await fn();
  } catch (exception, stackTrace) {
    final time = clock.now();
    log.add(LogEntry(time, level, 'Exception while $action'));
    log.add(LogEntry(time, exceptionLevel ?? level, '$exception\n$stackTrace'));
    return null;
  }
}
