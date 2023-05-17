import 'package:shared_preferences/shared_preferences.dart';
import 'dioUtil.dart';

isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  return token != null;
}

getToken() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  return token;
}

setToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

getBalance() async {
  final prefs = await SharedPreferences.getInstance();
  var balance = prefs.getDouble('balance');
  return balance;
}

setBalance(double balance) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('balance', balance);
}

logout() async {
  try {
    var dio = DioUtil.getInstance();
    var response = await dio.post('/auth/logout');
    if (response.statusCode == 200 && response.data['success']) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('balance');

      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e);
    return false;
  }
}
