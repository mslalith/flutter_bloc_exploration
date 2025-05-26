import 'package:dio/dio.dart';

class NumbersApiService {

  static final NumbersApiService instance = NumbersApiService._();

  NumbersApiService._();

  final _dio = Dio();

  Future<String?> fetchRandomNumberTrivia() async {
    final response = await _dio.get('http://numbersapi.com/random/trivia');
    if (response.statusCode != 200) return null;

    return response.data as String;
  }
}
