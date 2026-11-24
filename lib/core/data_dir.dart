import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// On Linux everything lives in ~/.local/share/untis-plus (or $XDG_DATA_HOME). Other platforms
/// keep the folder path_provider picks, [fallback] being their old one so no data moves.
Future<Directory> dataDir(Future<Directory> Function() fallback) async {
  if (!Platform.isLinux) return fallback();
  final env = Platform.environment;
  final base = env['XDG_DATA_HOME'] ?? '${env['HOME'] ?? (await getApplicationSupportDirectory()).path}/.local/share';
  return Directory('$base/untis-plus').create(recursive: true);
}
