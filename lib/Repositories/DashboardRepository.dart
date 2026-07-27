import 'package:salon_and_beauty/Models/DashboardData.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class DashboardRepository {
  Future<DashboardData> getDashboard() async {
    final response = await ApiClient().get('/dashboard');
    return DashboardData.fromJson(response.data['data']);
  }
}
