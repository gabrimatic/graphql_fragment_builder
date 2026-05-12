import 'query_fragment.dart';
import 'query_parameter.dart';

/// Supported GraphQL operation types.
enum GraphQLOperationType {
  /// A GraphQL query operation.
  query,

  /// A GraphQL mutation operation.
  mutation,

  /// A GraphQL subscription operation.
  subscription;

  /// The GraphQL keyword for this operation type.
  String get keyword => name;
}

/// A builder class for constructing GraphQL queries.
///
/// This class provides a flexible and type-safe way to build GraphQL queries
/// using a pattern-matching approach.
class GraphQLQueryBuilder {
  /// The root field name of the GraphQL operation.
  final String name;

  /// Optional GraphQL operation name.
  final String? operationName;

  /// The GraphQL operation type.
  final GraphQLOperationType operationType;

  /// The parameters to be included in the query.
  final List<QueryParameter> parameters;

  /// The fragments to be included in the query.
  final List<QueryFragment> fragments;

  /// Creates a new [GraphQLQueryBuilder] with the given [name], [parameters], and [fragments].
  GraphQLQueryBuilder({
    required this.name,
    this.operationName,
    this.operationType = GraphQLOperationType.query,
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
  /// This method returns the root field selection only. Use [buildDocument] when
  /// you need a complete `query`, `mutation`, or `subscription` operation.
  ///
  /// Returns a string representation of the GraphQL query.
  String buildQuery() {
    _validate();

    final buffer = StringBuffer(name);

    if (parameters.isNotEmpty) {
      buffer.write('(');
      buffer.writeAll(
        parameters.map((parameter) => parameter.argument),
        ', ',
      );
      buffer.write(')');
    }

    buffer.write(' {\n');

    for (final fragment in fragments) {
      buffer.write(_indent(fragment.fragment, 1));
      buffer.write('\n');
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Builds a complete GraphQL operation document.
  ///
  /// Parameters need a [QueryParameter.type] before they can be emitted as
  /// variable definitions.
  String buildDocument() {
    _validate();

    final buffer = StringBuffer(operationType.keyword);

    if (operationName != null) {
      buffer.write(' $operationName');
    }

    if (parameters.isNotEmpty) {
      buffer.write('(');
      buffer.writeAll(
        parameters.map((parameter) => parameter.definition),
        ', ',
      );
      buffer.write(')');
    }

    buffer.writeln(' {');
    buffer.writeln(_indent(buildQuery(), 1));
    buffer.write('}');

    return buffer.toString();
  }

  void _validate() {
    _validateGraphQLName(name, 'query name');

    final currentOperationName = operationName;
    if (currentOperationName != null) {
      _validateGraphQLName(currentOperationName, 'operation name');
    }

    for (final parameter in parameters) {
      parameter.validate();
    }

    if (fragments.isEmpty) {
      throw ArgumentError.value(
        fragments,
        'fragments',
        'A GraphQL query must include at least one fragment.',
      );
    }
  }
}

String _indent(String value, int levels) {
  final prefix = '  ' * levels;

  return value
      .split('\n')
      .map((line) => line.isEmpty ? line : '$prefix$line')
      .join('\n');
}

void _validateGraphQLName(String value, String label) {
  final isValid = RegExp(r'^[_A-Za-z][_0-9A-Za-z]*$').hasMatch(value);

  if (!isValid) {
    throw ArgumentError.value(
      value,
      label,
      'Must be a valid GraphQL name.',
    );
  }
}
