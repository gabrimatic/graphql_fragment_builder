/// Represents a parameter for a GraphQL query.
///
/// This class encapsulates the name and value of a query parameter,
/// providing type safety and ease of use when building queries.
class QueryParameter<T> {
  /// The name of the parameter as it appears in the GraphQL query.
  final String name;

  /// The value of the parameter.
  final T value;

  /// Creates a new [QueryParameter] with the given [name] and [value].
  const QueryParameter(this.name, this.value);

  /// Creates a map entry representation of this parameter.
  MapEntry<String, T> toMapEntry() => MapEntry(name, value);
}
