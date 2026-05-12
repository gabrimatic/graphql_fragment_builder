import 'graphql_writer.dart';
import 'query_parameter.dart';

/// Represents a selection inside a GraphQL operation.
abstract class QueryFragment {
  const QueryFragment();

  /// Returns the GraphQL selection string.
  String get fragment;

  /// Variables referenced by this selection and its children.
  List<QueryParameter> get referencedParameters => const [];

  /// Named fragment spreads referenced by this selection and its children.
  Set<String> get referencedFragmentNames => const {};
}

/// Represents a selectable GraphQL field.
///
/// Use this when a field needs arguments, an alias, or nested selections.
class QuerySelection extends QueryFragment {
  /// The field name as it appears in the GraphQL schema.
  final String name;

  /// Optional alias for this field.
  final String? alias;

  /// Field arguments. Arguments are emitted as GraphQL variables.
  final List<QueryParameter> parameters;

  /// Scalar fields selected under this field.
  final List<String> fields;

  /// Nested selections under this field.
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
  List<QueryParameter> get referencedParameters => [
        ...parameters,
        for (final fragment in fragments) ...fragment.referencedParameters,
      ];

  @override
  Set<String> get referencedFragmentNames => {
        for (final fragment in fragments) ...fragment.referencedFragmentNames,
      };

  @override
  String get fragment {
    _validate();

    final header = _fieldHeader(
      name: name,
      alias: alias,
      parameters: parameters,
    );

    return _selection(
      header: header,
      fields: fields,
      fragments: fragments,
    );
  }

  void _validate() {
    validateGraphQLName(name, 'selection name');

    final selectionAlias = alias;
    if (selectionAlias != null) {
      validateGraphQLName(selectionAlias, 'selection alias');
    }

    for (final parameter in parameters) {
      parameter.validate();
    }

    _validateFields(fields);
  }
}

/// A reference to a named GraphQL fragment definition.
class FragmentSpread extends QueryFragment {
  /// The fragment name, without the leading `...`.
  final String name;

  /// Creates a named fragment spread.
  const FragmentSpread(this.name);

  @override
  Set<String> get referencedFragmentNames => {name};

  @override
  String get fragment {
    validateGraphQLName(name, 'fragment spread name');
    return '...$name';
  }
}

/// A GraphQL inline fragment, usually used for interfaces and unions.
class InlineFragment extends QueryFragment {
  /// The GraphQL type condition.
  final String typeCondition;

  /// Scalar fields selected by the inline fragment.
  final List<String> fields;

  /// Nested selections inside the inline fragment.
  final List<QueryFragment> fragments;

  /// Creates an inline fragment.
  const InlineFragment({
    required this.typeCondition,
    this.fields = const [],
    this.fragments = const [],
  });

  @override
  List<QueryParameter> get referencedParameters => [
        for (final fragment in fragments) ...fragment.referencedParameters,
      ];

  @override
  Set<String> get referencedFragmentNames => {
        for (final fragment in fragments) ...fragment.referencedFragmentNames,
      };

  @override
  String get fragment {
    validateGraphQLName(typeCondition, 'inline fragment type condition');
    _validateFields(fields);

    return _selection(
      header: '... on $typeCondition',
      fields: fields,
      fragments: fragments,
      requireSelection: true,
    );
  }
}

/// A reusable named GraphQL fragment definition.
class GraphQLFragmentDefinition {
  /// The fragment name.
  final String name;

  /// The GraphQL type condition.
  final String typeCondition;

  /// Scalar fields selected by the fragment.
  final List<String> fields;

  /// Nested selections inside the fragment.
  final List<QueryFragment> fragments;

  /// Creates a named GraphQL fragment definition.
  const GraphQLFragmentDefinition({
    required this.name,
    required this.typeCondition,
    this.fields = const [],
    this.fragments = const [],
  });

  /// A spread that references this definition.
  FragmentSpread get spread => FragmentSpread(name);

  /// Variables referenced by this definition and its children.
  List<QueryParameter> get referencedParameters => [
        for (final fragment in fragments) ...fragment.referencedParameters,
      ];

  /// Named fragment spreads referenced by this definition and its children.
  Set<String> get referencedFragmentNames => {
        for (final fragment in fragments) ...fragment.referencedFragmentNames,
      };

  /// Returns the GraphQL fragment definition.
  String get definition {
    validateGraphQLName(name, 'fragment definition name');
    validateGraphQLName(typeCondition, 'fragment type condition');
    _validateFields(fields);

    return _selection(
      header: 'fragment $name on $typeCondition',
      fields: fields,
      fragments: fragments,
      requireSelection: true,
    );
  }
}

/// A mixin to easily create simple object selections.
mixin SimpleQueryFragment on QueryFragment {
  /// The fields to be included in the selection.
  List<String> get fields;

  /// The name of the selected object.
  String get objectName;

  @override
  String get fragment {
    validateGraphQLName(objectName, 'fragment object name');
    _validateFields(fields, requireNonEmpty: true);

    return _selection(
      header: objectName,
      fields: fields,
      fragments: const [],
      requireSelection: true,
    );
  }
}

String _fieldHeader({
  required String name,
  required String? alias,
  required List<QueryParameter> parameters,
}) {
  final fieldName = alias == null ? name : '$alias: $name';
  final arguments = parameters.isEmpty
      ? ''
      : '(${parameters.map((parameter) => parameter.argument).join(', ')})';

  return '$fieldName$arguments';
}

String _selection({
  required String header,
  required List<String> fields,
  required List<QueryFragment> fragments,
  bool requireSelection = false,
}) {
  final hasSelection = fields.isNotEmpty || fragments.isNotEmpty;

  if (!hasSelection) {
    if (requireSelection) {
      throw ArgumentError.value(
        fields,
        'fields',
        'A GraphQL selection must include at least one field or fragment.',
      );
    }

    return header;
  }

  final buffer = StringBuffer()..writeln('$header {');

  for (final field in fields) {
    buffer.writeln('  $field');
  }

  for (final fragment in fragments) {
    buffer.writeln(indentBlock(fragment.fragment, 1));
  }

  buffer.write('}');
  return buffer.toString();
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
    validateGraphQLName(field, 'field name');
  }
}
