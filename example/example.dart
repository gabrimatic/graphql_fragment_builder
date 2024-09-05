import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';

class BookDetailsFragment extends QueryFragment with SimpleQueryFragment {
  @override
  String get objectName => 'bookDetails';

  @override
  List<String> get fields => [
        'title',
        'author',
        'publicationYear',
        'genre',
      ];
}

void main() {
  final query = GraphQLQueryBuilder(
    name: 'getBooksByAuthor',
    parameters: const [
      QueryParameter('authorName', 'Jane Austen'),
      QueryParameter('limit', 5),
    ],
    fragments: [BookDetailsFragment()],
  );

  print('Query:');
  print(query.buildQuery());
  print('\nVariables:');
  print('${query.variables}');
}
