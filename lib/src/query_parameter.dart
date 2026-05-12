/// Represents a parameter for a GraphQL query.
///
/// This class encapsulates the name and value of a query parameter,
/// providing type safety and ease of use when building queries.
class QueryParameter<T> {
  /// The name of the parameter as it appears in the GraphQL query.
  final String name;

  /// The value of the parameter.
  final T value;

  /// The GraphQL variable type, for example `String`, `Int`, or `ID`.
  ///
  /// Set this when you want [GraphQLQueryBuilder.buildDocument] to include a
  /// variable definition in the generated operation.
  final String? type;

  /// Whether the GraphQL variable definition should be non-null.
  final bool isRequired;

  /// Creates a new [QueryParameter] with the given [name] and [value].
  const QueryParameter(
    this.name,
    this.value, {
    this.type,
    this.isRequired = false,
  });

  /// Creates a map entry representation of this parameter.
  MapEntry<String, T> toMapEntry() => MapEntry(name, value);

  /// Returns the GraphQL argument form for this parameter.
  String get argument => '$name: \$$name';

  /// Whether this parameter can be emitted as a GraphQL variable definition.
  bool get hasDefinition => type != null;

  /// Returns the GraphQL variable definition for this parameter.
  ///
  /// Throws a [StateError] when [type] is not set. This keeps the original
  /// lightweight query-building API usable while making full GraphQL operation
  /// documents explicit about variable types.
  String get definition {
    final variableType = type;

    if (variableType == null || variableType.trim().isEmpty) {
      throw StateError(
        'Parameter "$name" needs a GraphQL type before it can be used in '
        'an operation document.',
      );
    }

    return '\$$name: $variableType${isRequired ? '!' : ''}';
  }

  /// Validates this parameter's GraphQL-facing fields.
  void validate() {
    _validateGraphQLName(name, 'parameter name');

    final variableType = type;
    if (variableType != null && variableType.trim().isEmpty) {
      throw ArgumentError.value(
        variableType,
        'type',
        'GraphQL variable type cannot be empty.',
      );
    }
  }
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
