import 'customer_model.dart';

class DummyCustomers {
  static const CustomerModel activeCustomer = CustomerModel(
    id: 'cus-001',
    name: 'Siska Amanda',
    email: 'siska.amanda@example.com',
    phone: '0812-3456-7890',
    memberLevel: 'Gold',
    points: 1240,
  );

  static const List<CustomerModel> data = [
    activeCustomer,
    CustomerModel(
      id: 'cus-002',
      name: 'Nabila Zahra',
      email: 'nabila.zahra@example.com',
      phone: '0812-2400-8770',
      memberLevel: 'Silver',
      points: 680,
    ),
    CustomerModel(
      id: 'cus-003',
      name: 'Luna Citra',
      email: 'luna.citra@example.com',
      phone: '0813-7781-1109',
      memberLevel: 'Bronze',
      points: 320,
    ),
  ];
}
