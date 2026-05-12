import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';

class BookDetailsFragment extends QueryFragment with SimpleQueryFragment {
  @override
  String get objectName => 'book';

  @override
  List<String> get fields => [
        'id',
        'title',
        'publicationYear',
        'genre',
      ];
}

void main() {
  final query = GraphQLQueryBuilder(
    name: 'booksByAuthor',
    operationName: 'BooksByAuthor',
    parameters: const [
      QueryParameter(
        'authorName',
        'Jane Austen',
        type: 'String',
        isRequired: true,
      ),
      QueryParameter('limit', 5, type: 'Int'),
    ],
    fragments: [
      BookDetailsFragment(),
      const QuerySelection(
        name: 'reviews',
        parameters: [
          QueryParameter('limit', 3),
        ],
        fields: ['rating', 'body'],
      ),
    ],
  );

  print('Document:');
  print(query.buildDocument());
  print('\nVariables:');
  print('${query.variables}');
}
