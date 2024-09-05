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
    test('builds a simple query', () {
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

      expect(query, contains('testQuery(param1: \$param1, param2: \$param2)'));
      expect(query, contains('testObject {'));
      expect(query, contains('field1'));
      expect(query, contains('field2'));
      expect(query, contains('field3'));
      expect(variables, equals({'param1': 'value1', 'param2': 42}));
    });
  });
}
