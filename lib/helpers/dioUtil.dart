import 'package:Cookie/helpers/constants.dart';
import 'package:Cookie/helpers/functions.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioUtil {
  static dynamic _instance = null;

  static Dio getInstance() {
    if (_instance == null) {
      _instance = createDioInstance();
    }
    return _instance;
  }

  static Dio createDioInstance() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioError e, handler) async {
          if (e.response != null) {
            if (e.response?.statusCode == 401) {
              //catch the 401 here
              RequestOptions requestOptions = e.requestOptions;

              await refreshToken();
              String token = await getToken();
              final opts = new Options(method: requestOptions.method);
              dio.options.headers["Authorization"] = "Bearer " + token;
              final response = await dio.request(requestOptions.path,
                  options: opts,
                  cancelToken: requestOptions.cancelToken,
                  onReceiveProgress: requestOptions.onReceiveProgress,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters);
              handler.resolve(response);
            } else {
              handler.next(e);
            }
          }
        },
      ),
    );
    return dio;
  }

  static refreshToken() async {
    Response response;
    var dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    try {
      response = await dio.post('/auth/refresh');
      if (response.statusCode == 200) {
        var data = response.data;
        if (data['success']) {
          var token = data['access_token'];
          prefs.setString('token', token);
        }
      } else {
        print(response.toString()); //TODO: logout
      }
    } catch (e) {
      print(e.toString()); //TODO: logout
    }
  }
}
