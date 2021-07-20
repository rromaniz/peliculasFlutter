import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movies/models/models.dart';

String _apikey = 'a7223a9370b830ebb4d41859e186a0e0';
String _baseUrl = 'api.themoviedb.org';
String _language = 'es-ES';

class MoviesProvider extends ChangeNotifier {
  MoviesProvider() {
    print('Moviesprovider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsondata(String endpoint, [int page = 1]) async {
    var url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apikey, 'language': _language, '$page': '1'});

    final response = await http.get(url);
    return response.body;
  }

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};
  int popularPage = 0;

  getOnDisplayMovies() async {
    final jsonData = await _getJsondata('3/movie/now_playing');
    final nowplayingResponse = NowPlayingResp.fromJson(jsonData);
    onDisplayMovies = nowplayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    popularPage++;
    final jsonData = await _getJsondata('3/movie/now_playing', popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsondata('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }
}
