/// Represents a fragment of a GraphQL query.
///
/// This sealed class serves as a base for all query fragments,
/// allowing for type-safe pattern matching when building queries.
abstract class QueryFragment {
  const QueryFragment();

  /// Returns the GraphQL fragment string.
  String get fragment;
}

/// A mixin to easily create simple query fragments.
mixin SimpleQueryFragment on QueryFragment {
  /// The fields to be included in the fragment.
  List<String> get fields;

  /// The name of the fragment object.
  String get objectName;

  @override
  String get fragment => '''
    $objectName {
      ${fields.join('\n      ')}
    }
  ''';
}
