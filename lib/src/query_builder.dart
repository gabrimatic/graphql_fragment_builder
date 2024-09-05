import 'query_fragment.dart';
import 'query_parameter.dart';

/// A builder class for constructing GraphQL queries.
///
/// This class provides a flexible and type-safe way to build GraphQL queries
/// using a pattern-matching approach.
class GraphQLQueryBuilder {
  /// The name of the GraphQL query.
  final String name;

  /// The parameters to be included in the query.
  final List<QueryParameter> parameters;

  /// The fragments to be included in the query.
  final List<QueryFragment> fragments;

  /// Creates a new [GraphQLQueryBuilder] with the given [name], [parameters], and [fragments].
  GraphQLQueryBuilder({
    required this.name,
    this.parameters = const [],
    this.fragments = const [],
  });

  /// Generates a map of variables for the GraphQL query.
  ///
  /// This map is used when sending the query to the GraphQL server.
  Map<String, dynamic> get variables => Map.fromEntries(
        parameters.map((p) => p.toMapEntry()),
      );

  /// Builds the complete GraphQL query string.
  ///
  /// This method constructs the query by combining the query name,
  /// parameters, and selected fragments.
  ///
  /// Returns a string representation of the GraphQL query.
  String buildQuery() {
    final buffer = StringBuffer(name);

    if (parameters.isNotEmpty) {
      buffer.write('(');
      buffer.writeAll(
        parameters.map((p) => '${p.name}: \$${p.name}'),
        ', ',
      );
      buffer.write(')');
    }

    buffer.write(' {\n');

    for (final fragment in fragments) {
      buffer.write('  ${fragment.fragment}\n');
    }

    buffer.write('}');
    return buffer.toString();
  }
}
