import 'query_parameter.dart';

/// Represents a fragment of a GraphQL query.
///
/// This sealed class serves as a base for all query fragments,
/// allowing for type-safe pattern matching when building queries.
abstract class QueryFragment {
  const QueryFragment();

  /// Returns the GraphQL fragment string.
  String get fragment;
}

/// Represents a selectable GraphQL field.
///
/// Use this when a field needs arguments, an alias, or nested fragments.
class QuerySelection extends QueryFragment {
  /// The field name as it appears in the GraphQL schema.
  final String name;

  /// Optional alias for this field.
  final String? alias;

  /// Field arguments.
  final List<QueryParameter> parameters;

  /// Scalar fields selected under this field.
  final List<String> fields;

  /// Nested selection fragments.
  final List<QueryFragment> fragments;

  /// Creates a reusable GraphQL field selection.
  const QuerySelection({
    required this.name,
    this.alias,
    this.parameters = const [],
    this.fields = const [],
    this.fragments = const [],
  });

  @override
  String get fragment {
    _validateGraphQLName(name, 'selection name');

    final selectionAlias = alias;
    if (selectionAlias != null) {
      _validateGraphQLName(selectionAlias, 'selection alias');
    }

    for (final parameter in parameters) {
      parameter.validate();
    }

    _validateFields(fields);

    final buffer = StringBuffer();
    _writeSelection(buffer, indentLevel: 0);
    return buffer.toString();
  }

  void _writeSelection(StringBuffer buffer, {required int indentLevel}) {
    final indent = '  ' * indentLevel;
    final fieldName = alias == null ? name : '$alias: $name';
    final arguments = parameters.isEmpty
        ? ''
        : '(${parameters.map((parameter) => parameter.argument).join(', ')})';

    buffer.write('$indent$fieldName$arguments');

    if (fields.isEmpty && fragments.isEmpty) {
      return;
    }

    buffer.writeln(' {');

    for (final field in fields) {
      buffer.writeln('${'  ' * (indentLevel + 1)}$field');
    }

    for (final fragment in fragments) {
      final nested = fragment.fragment.split('\n');

      for (final line in nested) {
        if (line.trim().isEmpty) {
          continue;
        }

        buffer.writeln('${'  ' * (indentLevel + 1)}$line');
      }
    }

    buffer.write('$indent}');
  }
}

/// A mixin to easily create simple query fragments.
mixin SimpleQueryFragment on QueryFragment {
  /// The fields to be included in the fragment.
  List<String> get fields;

  /// The name of the fragment object.
  String get objectName;

  @override
  String get fragment {
    _validateGraphQLName(objectName, 'fragment object name');
    _validateFields(fields, requireNonEmpty: true);

    final buffer = StringBuffer()..writeln('$objectName {');

    for (final field in fields) {
      buffer.writeln('  $field');
    }

    buffer.write('}');
    return buffer.toString();
  }
}

void _validateFields(
  List<String> fields, {
  bool requireNonEmpty = false,
}) {
  if (requireNonEmpty && fields.isEmpty) {
    throw ArgumentError.value(
      fields,
      'fields',
      'A GraphQL selection must include at least one field.',
    );
  }

  for (final field in fields) {
    _validateGraphQLName(field, 'field name');
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
