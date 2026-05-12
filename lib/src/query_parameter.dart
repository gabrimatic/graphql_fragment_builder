import 'graphql_writer.dart';

/// Represents a parameter for a GraphQL query.
///
/// This class encapsulates the name and value of a query parameter,
/// providing type safety and ease of use when building queries.
class QueryParameter<T> {
  /// The name of the parameter as it appears in the GraphQL query.
  ///
  /// By default this is used as both the GraphQL argument name and variable
  /// name. Set [argumentName] when the schema argument and variable should have
  /// different names.
  final String name;

  /// The value of the parameter.
  final T value;

  /// Optional GraphQL argument name.
  final String? argumentName;

  /// The GraphQL variable type, for example `String`, `Int`, or `ID`.
  ///
  /// Set this when you want [GraphQLQueryBuilder.buildDocument] to include a
  /// variable definition in the generated operation.
  final String? type;

  /// Whether the GraphQL variable definition should be non-null.
  final bool isRequired;

  /// Optional raw GraphQL default value for the variable definition.
  ///
  /// Example: `defaultValue: '10'` produces `$limit: Int = 10`.
  final String? defaultValue;

  /// Creates a new [QueryParameter] with the given [name] and [value].
  const QueryParameter(
    this.name,
    this.value, {
    this.argumentName,
    this.type,
    this.isRequired = false,
    this.defaultValue,
  });

  /// Creates a map entry representation of this parameter.
  MapEntry<String, T> toMapEntry() => MapEntry(name, value);

  /// Returns the GraphQL argument form for this parameter.
  String get argument => '${argumentName ?? name}: \$$name';

  /// Whether this parameter can be emitted as a GraphQL variable definition.
  bool get hasDefinition => type != null && type!.trim().isNotEmpty;

  /// Returns the GraphQL variable definition for this parameter.
  ///
  /// Throws a [StateError] when [type] is not set. This keeps the original
  /// lightweight query-building API usable while making full GraphQL operation
  /// documents explicit about variable types.
  String get definition {
    final variableType = _definitionType;

    if (variableType == null) {
      throw StateError(
        'Parameter "$name" needs a GraphQL type before it can be used in '
        'an operation document.',
      );
    }

    final defaultValue = this.defaultValue;
    if (defaultValue == null) {
      return '\$$name: $variableType';
    }

    return '\$$name: $variableType = $defaultValue';
  }

  /// Validates this parameter's GraphQL-facing fields.
  void validate({bool requireType = false}) {
    validateGraphQLName(name, 'parameter name');

    final argumentName = this.argumentName;
    if (argumentName != null) {
      validateGraphQLName(argumentName, 'argument name');
    }

    final variableType = type;
    if (requireType && (variableType == null || variableType.trim().isEmpty)) {
      throw StateError(
        'Parameter "$name" needs a GraphQL type before it can be used in '
        'an operation document.',
      );
    }

    if (variableType != null) {
      if (variableType.trim().isEmpty) {
        throw ArgumentError.value(
          variableType,
          'type',
          'GraphQL variable type cannot be empty.',
        );
      }

      validateGraphQLType(variableType, 'type');
    }

    final defaultValue = this.defaultValue;
    if (defaultValue != null && defaultValue.trim().isEmpty) {
      throw ArgumentError.value(
        defaultValue,
        'defaultValue',
        'GraphQL variable default value cannot be empty.',
      );
    }
  }

  String? get _definitionType {
    final variableType = type?.trim();
    if (variableType == null || variableType.isEmpty) {
      return null;
    }

    if (variableType.endsWith('!') || !isRequired) {
      return variableType;
    }

    return '$variableType!';
  }
}
