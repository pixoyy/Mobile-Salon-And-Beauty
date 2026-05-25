import 'user_model.dart';

class DummyUser {

  /// USER AKTIF YANG BISA BERUBAH
  static UserModel activeCustomer = const UserModel(
    id: 'demo-001',
    name: 'user',
    email: 'user@gmail.com',
    phone: '081234567890',
    password: 'test123',
  );

  /// DATA DUMMY
  static List<UserModel> data = [
    activeCustomer,

    const UserModel(
      id: 'cus-002',
      name: 'Nabila Zahra',
      email: 'nabila.zahra@example.com',
      phone: '081234567891',
      password: 'password123',
    ),

    const UserModel(
      id: 'cus-003',
      name: 'Luna Citra',
      email: 'luna.citra@example.com',
      phone: '081234567892',
      password: 'password123',
    ),
  ];
}