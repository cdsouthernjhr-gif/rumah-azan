import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../local/database.dart';
import '../models/content_item.dart';

class ContentRepository {
  ContentRepository(this.db, {AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AppDatabase db;
  final AssetBundle _bundle;

  List<ContentItem>? _cache;

  Future<List<ContentItem>> all() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString('assets/data/content.json');
    _cache = parseContent(raw);
    return _cache!;
  }

  static List<ContentItem> parseContent(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return [for (final e in j['items'] as List) ContentItem.fromJson(e as Map<String, dynamic>)];
  }

  Future<List<ContentItem>> byCategory(String cat) async =>
      (await all()).where((e) => e.categories.contains(cat)).toList();

  Stream<Set<String>> watchFavorites() =>
      db.select(db.favorites).watch().map((rows) => rows.map((r) => r.contentId).toSet());

  Future<void> toggleFavorite(String id) async {
    final existing = await (db.select(db.favorites)..where((t) => t.contentId.equals(id))).getSingleOrNull();
    if (existing != null) {
      await (db.delete(db.favorites)..where((t) => t.contentId.equals(id))).go();
    } else {
      await db.into(db.favorites).insert(FavoritesCompanion.insert(contentId: id, createdAt: Value(DateTime.now().toUtc())));
    }
  }
}
