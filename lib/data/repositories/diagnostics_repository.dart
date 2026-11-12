import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/database.dart';

/// Persistent, size-bounded application log shown in the Diagnostics screen.
/// Never stores personal data (no coordinates, no file contents).
class DiagnosticsRepository {
  DiagnosticsRepository(this.db);
  final AppDatabase db;

  static const maxRows = 500;

  Future<void> log(String level, String tag, String message) async {
    debugPrint('[$level][$tag] $message');
    try {
      await db.into(db.appDiagnostics).insert(AppDiagnosticsCompanion.insert(
            level: level,
            tag: tag,
            message: message.length > 1000 ? message.substring(0, 1000) : message,
            createdAt: Value(DateTime.now().toUtc()),
          ));
      await db.customStatement(
        'DELETE FROM app_diagnostics WHERE id NOT IN '
        '(SELECT id FROM app_diagnostics ORDER BY id DESC LIMIT $maxRows)',
      );
    } catch (e) {
      debugPrint('diagnostics log failed: $e');
    }
  }

  Future<void> info(String tag, String m) => log('info', tag, m);
  Future<void> warn(String tag, String m) => log('warn', tag, m);
  Future<void> error(String tag, String m) => log('error', tag, m);

  Future<List<DiagnosticRow>> recent([int limit = 100]) => (db.select(db.appDiagnostics)
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(limit))
      .get();

  Future<DiagnosticRow?> lastWhere(String tag, {String? level}) => (db.select(db.appDiagnostics)
        ..where((t) => t.tag.equals(tag) & (level == null ? const Constant(true) : t.level.equals(level)))
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(1))
      .getSingleOrNull();

  Future<void> clear() => db.delete(db.appDiagnostics).go();
}
