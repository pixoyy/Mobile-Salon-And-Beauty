import 'package:sqflite/sqflite.dart';

import '../models/discount.dart';
import 'database_helper.dart';
import 'dummy_discounts.dart';

class DiscountRepository {
  static final DiscountRepository _instance = DiscountRepository._internal();

  factory DiscountRepository() {
    return _instance;
  }

  DiscountRepository._internal();

  List<Discount> _cache = List<Discount>.unmodifiable(DummyDiscounts.data);

  Future<List<Discount>> getAllDiscounts() async {
    try {
      final Database db = await DatabaseHelper.instance.database;
      final List<Map<String, Object?>> rows = await db.query('discounts');
      if (rows.isEmpty) {
        _cache = List<Discount>.unmodifiable(DummyDiscounts.data);
        return _cache;
      }

      final List<Discount> discounts = rows
          .map((row) => Discount.fromMap(row))
          .toList(growable: false);
      _cache = List<Discount>.unmodifiable(discounts);
      return _cache;
    } catch (_) {
      return _cache;
    }
  }
}