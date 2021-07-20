import 'package:flutter/material.dart';

@override
String get searchFieldLabel => 'Buscar';

class MovieSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [Text('BuildActions')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Text('BuildLeading');
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('BuildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text('BuildSuggestions: $query');
  }
}
