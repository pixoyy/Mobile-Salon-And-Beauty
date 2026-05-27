import 'package:salon_and_beauty/core/data/database_helper.dart';
import 'dummy_stylists.dart';
import 'stylist_model.dart';

class StylistRepository {
  factory StylistRepository() {
    _instance ??= StylistRepository._internal();
    return _instance!;
  }

  StylistRepository._internal() {
    _initializeDummyStylists();
  }

  static StylistRepository? _instance;

  final List<StylistModel> _stylists = <StylistModel>[];

  void _initializeDummyStylists() {
    if (_stylists.isNotEmpty) {
      return;
    }

    _stylists.addAll(DummyStylists.data);
  }

  Future<List<StylistModel>> getAllStylists() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('stylists');
      if (rows.isEmpty) {
        return List<StylistModel>.from(_stylists);
      }

      return rows
          .map((r) => StylistModel.fromMap(r))
          .toList(growable: false);
    } catch (_) {
      return List<StylistModel>.from(_stylists);
    }
  }

  Future<StylistModel?> getStylistById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('stylists', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) {
        try {
          return _stylists.firstWhere((s) => s.id == id);
        } catch (_) {
          return null;
        }
      }

      return StylistModel.fromMap(rows.first);
    } catch (_) {
      try {
        return _stylists.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<StylistModel>> searchStylists(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllStylists();
    }
    await Future<void>.delayed(const Duration(milliseconds: 180));

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('stylists');
      final List<StylistModel> all = rows
          .map((r) => StylistModel.fromMap(r))
          .toList(growable: false);

      return all.where((stylist) {
        final name = stylist.name.toLowerCase();
        final specialization = stylist.specialization.toLowerCase();
        final skills = stylist.skills.join(' ').toLowerCase();

        return name.contains(normalizedQuery) ||
            specialization.contains(normalizedQuery) ||
            skills.contains(normalizedQuery);
      }).toList(growable: false);
    } catch (_) {
      return _stylists.where((stylist) {
        final name = stylist.name.toLowerCase();
        final specialization = stylist.specialization.toLowerCase();
        final skills = stylist.skills.join(' ').toLowerCase();

        return name.contains(normalizedQuery) ||
            specialization.contains(normalizedQuery) ||
            skills.contains(normalizedQuery);
      }).toList(growable: false);
    }
  }
}