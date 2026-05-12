import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';
import 'package:test/test.dart';

class TestFragment extends QueryFragment with SimpleQueryFragment {
  @override
  String get objectName => 'testObject';

  @override
  List<String> get fields => ['field1', 'field2', 'field3'];
}

void main() {
  group('GraphQLQueryBuilder', () {
    test('builds a root field selection for existing callers', () {
      final builder = GraphQLQueryBuilder(
        name: 'testQuery',
        parameters: const [
          QueryParameter('param1', 'value1'),
          QueryParameter('param2', 42),
        ],
        fragments: [TestFragment()],
      );

      final query = builder.buildQuery();
      final variables = builder.variables;

      expect(
        query,
        equals('''
testQuery(param1: \$param1, param2: \$param2) {
  testObject {
    field1
    field2
    field3
  }
}'''),
      );
      expect(variables, equals({'param1': 'value1', 'param2': 42}));
    });

    test('builds a complete operation document with variable definitions', () {
      final builder = GraphQLQueryBuilder(
        name: 'book',
        operationName: 'GetBook',
        parameters: const [
          QueryParameter('id', 'book-1', type: 'ID', isRequired: true),
        ],
        fragments: const [
          QuerySelection(
            name: 'author',
            alias: 'primaryAuthor',
            fields: ['name'],
          ),
        ],
      );

      expect(
        builder.buildDocument(),
        equals('''
query GetBook(\$id: ID!) {
  book(id: \$id) {
    primaryAuthor: author {
      name
    }
  }
}'''),
      );
    });

    test('collects variables from nested selections', () {
      const builder = GraphQLQueryBuilder(
        name: 'booksByAuthor',
        operationName: 'BooksByAuthor',
        parameters: [
          QueryParameter(
            'authorName',
            'Jane Austen',
            type: 'String',
            isRequired: true,
          ),
        ],
        fragments: [
          QuerySelection(
            name: 'reviews',
            parameters: [
              QueryParameter('reviewLimit', 3,
                  argumentName: 'limit', type: 'Int'),
            ],
            fields: ['rating', 'body'],
          ),
        ],
      );

      expect(
        builder.buildDocument(),
        equals('''
query BooksByAuthor(\$authorName: String!, \$reviewLimit: Int) {
  booksByAuthor(authorName: \$authorName) {
    reviews(limit: \$reviewLimit) {
      rating
      body
    }
  }
}'''),
      );
      expect(builder.variables,
          equals({'authorName': 'Jane Austen', 'reviewLimit': 3}));
    });

    test('supports mutation operation documents', () {
      final builder = GraphQLQueryBuilder(
        name: 'updateBookTitle',
        operationType: GraphQLOperationType.mutation,
        operationName: 'UpdateBookTitle',
        parameters: const [
          QueryParameter('id', 'book-1', type: 'ID', isRequired: true),
          QueryParameter('title', 'Persuasion', type: 'String'),
        ],
        fragments: const [
          QuerySelection(
            name: 'book',
            fields: ['id', 'title'],
          ),
        ],
      );

      expect(
        builder.buildDocument(),
        equals('''
mutation UpdateBookTitle(\$id: ID!, \$title: String) {
  updateBookTitle(id: \$id, title: \$title) {
    book {
      id
      title
    }
  }
}'''),
      );
    });

    test('rejects invalid GraphQL names', () {
      final builder = GraphQLQueryBuilder(
        name: 'invalid-name',
        fragments: [TestFragment()],
      );

      expect(builder.buildQuery, throwsArgumentError);
    });

    test('rejects invalid argument names', () {
      const selection = QuerySelection(
        name: 'reviews',
        parameters: [
          QueryParameter('reviewLimit', 3, argumentName: 'bad-name'),
        ],
        fields: ['rating'],
      );

      expect(() => selection.fragment, throwsArgumentError);
    });

    test('requires parameter types for operation documents', () {
      final builder = GraphQLQueryBuilder(
        name: 'testQuery',
        parameters: const [
          QueryParameter('id', 'book-1'),
        ],
        fragments: [TestFragment()],
      );

      expect(builder.buildDocument, throwsStateError);
    });

    test('builds scalar root operation documents without nested selections',
        () {
      const builder = GraphQLQueryBuilder(
        name: 'serverVersion',
        operationName: 'ServerVersion',
      );

      expect(
        builder.buildDocument(),
        equals('''
query ServerVersion {
  serverVersion
}'''),
      );
      expect(builder.variables, isEmpty);
    });

    test('rejects dotted fields so nested selections stay explicit', () {
      const selection = QuerySelection(name: 'book', fields: ['author.name']);

      expect(() => selection.fragment, throwsArgumentError);
    });

    test('rejects conflicting duplicate variables', () {
      const builder = GraphQLQueryBuilder(
        name: 'books',
        parameters: [
          QueryParameter('limit', 5, type: 'Int'),
        ],
        fragments: [
          QuerySelection(
            name: 'reviews',
            parameters: [
              QueryParameter('limit', 3, type: 'Int'),
            ],
            fields: ['rating'],
          ),
        ],
      );

      expect(builder.buildDocument, throwsArgumentError);
    });

    test('rejects invalid GraphQL variable types', () {
      const builder = GraphQLQueryBuilder(
        name: 'book',
        parameters: [
          QueryParameter('id', 'book-1', type: '[ID'),
        ],
        fragments: [
          QuerySelection(name: 'author', fields: ['name']),
        ],
      );

      expect(builder.buildDocument, throwsArgumentError);
    });

    test('builds named fragment definitions and spreads', () {
      const bookFields = GraphQLFragmentDefinition(
        name: 'BookFields',
        typeCondition: 'Book',
        fields: ['id', 'title'],
      );
      const builder = GraphQLQueryBuilder(
        name: 'book',
        operationName: 'GetBook',
        parameters: [
          QueryParameter('id', 'book-1', type: 'ID', isRequired: true),
        ],
        fragments: [
          FragmentSpread('BookFields'),
        ],
        fragmentDefinitions: [
          bookFields,
        ],
      );

      expect(
        builder.buildDocument(),
        equals('''
query GetBook(\$id: ID!) {
  book(id: \$id) {
    ...BookFields
  }
}

fragment BookFields on Book {
  id
  title
}'''),
      );
    });

    test('rejects fragment spreads without matching definitions in documents',
        () {
      const builder = GraphQLQueryBuilder(
        name: 'book',
        fragments: [
          FragmentSpread('MissingFields'),
        ],
      );

      expect(builder.buildDocument, throwsArgumentError);
    });

    test('builds inline fragments for union selections', () {
      const builder = GraphQLQueryBuilder(
        name: 'search',
        operationName: 'Search',
        parameters: [
          QueryParameter('text', 'dart', type: 'String', isRequired: true),
        ],
        fragments: [
          InlineFragment(
            typeCondition: 'Book',
            fields: ['title'],
          ),
          InlineFragment(
            typeCondition: 'Author',
            fields: ['name'],
          ),
        ],
      );

      expect(
        builder.buildDocument(),
        equals('''
query Search(\$text: String!) {
  search(text: \$text) {
    ... on Book {
      title
    }
    ... on Author {
      name
    }
  }
}'''),
      );
    });
  });
}
