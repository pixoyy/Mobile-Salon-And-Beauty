import 'user_model.dart';

class DummyUser {
  static const UserModel activeCustomer = UserModel(
    id: 'demo-001',
    name: 'user',
    email: 'user@gmail.com',
    password: 'test123',
  );

  static const List<UserModel> data = [
    activeCustomer,
    UserModel(
      id: 'demo-001',
      name: 'user',
      email: 'user@gmail.com',
      password: 'test123',
    ),
    UserModel(
      id: 'cus-002',
      name: 'Nabila Zahra',
      email: 'nabila.zahra@example.com',
      password: 'password123',
    ),
    UserModel(
      id: 'cus-003',
      name: 'Luna Citra',
      email: 'luna.citra@example.com',
      password: 'password123',
    ),
  ];
}
