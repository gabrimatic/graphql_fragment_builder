import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';

const bookFields = GraphQLFragmentDefinition(
  name: 'BookFields',
  typeCondition: 'Book',
  fields: ['id', 'title', 'publicationYear', 'genre'],
);

void main() {
  const query = GraphQLQueryBuilder(
    name: 'booksByAuthor',
    operationName: 'BooksByAuthor',
    parameters: [
      QueryParameter(
        'authorName',
        'Jane Austen',
        type: 'String',
        isRequired: true,
      ),
      QueryParameter(
        'bookLimit',
        5,
        argumentName: 'limit',
        type: 'Int',
      ),
    ],
    fragments: [
      FragmentSpread('BookFields'),
      QuerySelection(
        name: 'reviews',
        parameters: [
          QueryParameter(
            'reviewLimit',
            3,
            argumentName: 'limit',
            type: 'Int',
          ),
        ],
        fields: ['rating', 'body'],
      ),
    ],
    fragmentDefinitions: [bookFields],
  );

  print('Document:');
  print(query.buildDocument());
  print('\nVariables:');
  print('${query.variables}');
}
