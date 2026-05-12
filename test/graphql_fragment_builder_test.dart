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

    test('rejects dotted fields so nested selections stay explicit', () {
      const selection = QuerySelection(name: 'book', fields: ['author.name']);

      expect(() => selection.fragment, throwsArgumentError);
    });
  });
}
