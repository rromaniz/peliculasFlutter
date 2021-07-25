import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movies/helpers/debouncer.dart';
import 'package:movies/models/models.dart';
import 'package:movies/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _apikey = 'a7223a9370b830ebb4d41859e186a0e0';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';
  int popularPage = 0;

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamContoller =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      this._suggestionStreamContoller.stream;

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

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apikey, 'language': _language, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = "";
    debouncer.onValue = (value) async {
      final results = await this.searchMovies(value);
      this._suggestionStreamContoller.add(results);
    };
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
