import 'graphql_writer.dart';
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

/// Builds GraphQL root selections and full operation documents.
class GraphQLQueryBuilder {
  /// The root field name of the GraphQL operation.
  final String name;

  /// Optional GraphQL operation name.
  final String? operationName;

  /// The GraphQL operation type.
  final GraphQLOperationType operationType;

  /// Arguments on the root field. Arguments are emitted as GraphQL variables.
  final List<QueryParameter> parameters;

  /// Selections under the root field.
  final List<QueryFragment> fragments;

  /// Named fragment definitions appended to full operation documents.
  final List<GraphQLFragmentDefinition> fragmentDefinitions;

  /// Creates a new [GraphQLQueryBuilder].
  const GraphQLQueryBuilder({
    required this.name,
    this.operationName,
    this.operationType = GraphQLOperationType.query,
    this.parameters = const [],
    this.fragments = const [],
    this.fragmentDefinitions = const [],
  });

  /// Generates a map of variables referenced by the operation tree.
  ///
  /// Duplicate variable names are allowed only when they resolve to the same
  /// value and compatible metadata.
  Map<String, dynamic> get variables => Map.fromEntries(
        _mergedParameters().map((parameter) => parameter.toMapEntry()),
      );

  /// Builds the root field selection.
  ///
  /// Use [buildDocument] when you need a complete `query`, `mutation`, or
  /// `subscription` operation.
  String buildQuery() {
    _validate();

    final header = _rootFieldHeader();
    if (fragments.isEmpty) {
      return header;
    }

    final buffer = StringBuffer()..writeln('$header {');

    for (final fragment in fragments) {
      buffer.writeln(indentBlock(fragment.fragment, 1));
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Builds a complete GraphQL operation document.
  ///
  /// Every referenced [QueryParameter] needs a GraphQL type before it can be
  /// emitted as a variable definition.
  String buildDocument() {
    _validate(requireDocument: true);

    final operationParameters = _mergedParameters(requireTypes: true);
    final buffer = StringBuffer(operationType.keyword);

    if (operationName != null) {
      buffer.write(' $operationName');
    }

    if (operationParameters.isNotEmpty) {
      buffer.write('(');
      buffer.writeAll(
        operationParameters.map((parameter) => parameter.definition),
        ', ',
      );
      buffer.write(')');
    }

    buffer.writeln(' {');
    buffer.writeln(indentBlock(buildQuery(), 1));
    buffer.write('}');

    if (fragmentDefinitions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln();
      buffer.write(
        fragmentDefinitions
            .map((definition) => definition.definition)
            .join('\n\n'),
      );
    }

    return buffer.toString();
  }

  String _rootFieldHeader() {
    final arguments = parameters.isEmpty
        ? ''
        : '(${parameters.map((parameter) => parameter.argument).join(', ')})';

    return '$name$arguments';
  }

  void _validate({bool requireDocument = false}) {
    validateGraphQLName(name, 'query name');

    final currentOperationName = operationName;
    if (currentOperationName != null) {
      validateGraphQLName(currentOperationName, 'operation name');
    }

    _mergedParameters(requireTypes: requireDocument);
    _validateFragmentDefinitions(requireDocument: requireDocument);
  }

  void _validateFragmentDefinitions({required bool requireDocument}) {
    final definitions = <String>{};

    for (final definition in fragmentDefinitions) {
      validateGraphQLName(definition.name, 'fragment definition name');

      if (!definitions.add(definition.name)) {
        throw ArgumentError.value(
          definition.name,
          'fragmentDefinitions',
          'Duplicate GraphQL fragment definition.',
        );
      }

      definition.definition;
    }

    if (!requireDocument) {
      return;
    }

    final referenced = <String>{
      for (final fragment in fragments) ...fragment.referencedFragmentNames,
      for (final definition in fragmentDefinitions)
        ...definition.referencedFragmentNames,
    };
    final missing = referenced.difference(definitions);

    if (missing.isNotEmpty) {
      throw ArgumentError.value(
        missing.join(', '),
        'fragmentDefinitions',
        'Every fragment spread in a document needs a matching definition.',
      );
    }
  }

  List<QueryParameter> _allParameters() => [
        ...parameters,
        for (final fragment in fragments) ...fragment.referencedParameters,
        for (final definition in fragmentDefinitions)
          ...definition.referencedParameters,
      ];

  List<QueryParameter> _mergedParameters({bool requireTypes = false}) {
    final registry = _ParameterRegistry();

    for (final parameter in _allParameters()) {
      registry.add(parameter);
    }

    final merged = registry.parameters;

    if (requireTypes) {
      for (final parameter in merged) {
        parameter.validate(requireType: true);
      }
    }

    return merged;
  }
}

class _ParameterRegistry {
  final _parameters = <String, QueryParameter>{};

  List<QueryParameter> get parameters => _parameters.values.toList();

  void add(QueryParameter parameter) {
    parameter.validate();

    final current = _parameters[parameter.name];
    if (current == null) {
      _parameters[parameter.name] = parameter;
      return;
    }

    _parameters[parameter.name] = _merge(current, parameter);
  }

  QueryParameter _merge(
    QueryParameter current,
    QueryParameter incoming,
  ) {
    if (current.value != incoming.value) {
      throw ArgumentError.value(
        incoming.name,
        'parameters',
        'Duplicate GraphQL variables must use the same value.',
      );
    }

    final type = _mergeOptional(
      'type',
      current.type,
      incoming.type,
      incoming.name,
    );
    final defaultValue = _mergeOptional(
      'defaultValue',
      current.defaultValue,
      incoming.defaultValue,
      incoming.name,
    );

    return QueryParameter(
      current.name,
      current.value,
      argumentName: current.argumentName ?? incoming.argumentName,
      type: type,
      isRequired: current.isRequired || incoming.isRequired,
      defaultValue: defaultValue,
    );
  }

  String? _mergeOptional(
    String field,
    String? current,
    String? incoming,
    String name,
  ) {
    final currentValue = current?.trim();
    final incomingValue = incoming?.trim();

    if (currentValue == null || currentValue.isEmpty) {
      return incomingValue;
    }

    if (incomingValue == null || incomingValue.isEmpty) {
      return currentValue;
    }

    if (currentValue != incomingValue) {
      throw ArgumentError.value(
        name,
        'parameters',
        'Duplicate GraphQL variable "$name" has conflicting $field values.',
      );
    }

    return currentValue;
  }
}
