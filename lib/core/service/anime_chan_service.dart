import 'package:dio/dio.dart';
import 'package:flutter_bloc_exploration/core/models/anime_quote.dart';

class AnimeChanService {

  static final AnimeChanService instance = AnimeChanService._();

  AnimeChanService._();

  final _dio = Dio();

  Future<AnimeQuote?> fetchAnimeQuote() async {
    final response = await _dio.get('https://api.animechan.io/v1/quotes/random');
    if (response.statusCode != 200) return null;

    return AnimeQuote.fromJson(response.data as Map<String, dynamic>);
  }
}
