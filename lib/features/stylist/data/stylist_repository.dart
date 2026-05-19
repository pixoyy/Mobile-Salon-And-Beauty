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
    return List<StylistModel>.from(_stylists);
  }

  Future<StylistModel?> getStylistById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    for (final stylist in _stylists) {
      if (stylist.id == id) {
        return stylist;
      }
    }

    return null;
  }

  Future<List<StylistModel>> searchStylists(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllStylists();
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));

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