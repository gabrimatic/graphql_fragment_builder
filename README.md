# GraphQL Fragment Builder

[![Dart CI](https://github.com/gabrimatic/graphql_fragment_builder/actions/workflows/dart.yml/badge.svg)](https://github.com/gabrimatic/graphql_fragment_builder/actions/workflows/dart.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

GraphQL Fragment Builder is a small Dart package for building GraphQL selection sets, variables, and operation documents without assembling strings by hand. It is useful when a Flutter or Dart app needs a compact query builder, but not a full GraphQL client.

## Quick Start

Runtime: **Dart >= 3.5.1**.

Add the package:

```yaml
dependencies:
  graphql_fragment_builder: ^1.1.0
```

Import it:

```dart
import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';
```

Build a complete operation document:

```dart
final query = GraphQLQueryBuilder(
  name: 'book',
  operationName: 'GetBook',
  parameters: const [
    QueryParameter('id', 'book-1', type: 'ID', isRequired: true),
  ],
  fragments: const [
    QuerySelection(
      name: 'author',
      alias: 'primaryAuthor',
      fields: ['name'],
    ),
  ],
);

print(query.buildDocument());
print(query.variables);
```

Output:

```graphql
query GetBook($id: ID!) {
  book(id: $id) {
    primaryAuthor: author {
      name
    }
  }
}
```

```dart
{id: book-1}
```

## What It Builds

The package has two output modes:

| Method | Output | Use it when |
| --- | --- | --- |
| `buildQuery()` | A root field selection | Your GraphQL client wraps the operation for you |
| `buildDocument()` | A full `query`, `mutation`, or `subscription` document | You send the document string yourself |

## Selection Sets

Use `SimpleQueryFragment` when you only need a named object and scalar fields:

```dart
class BookDetailsFragment extends QueryFragment with SimpleQueryFragment {
  @override
  String get objectName => 'book';

  @override
  List<String> get fields => ['id', 'title', 'publishedAt'];
}
```

Use `QuerySelection` when the field needs arguments, an alias, or nested selections:

```dart
const QuerySelection(
  name: 'reviews',
  parameters: [
    QueryParameter('limit', 3),
  ],
  fields: ['rating', 'body'],
);
```

Field arguments use GraphQL variables. If you call `buildDocument()`, include the matching typed `QueryParameter` in the root builder so the operation can emit the variable definition.

## Operations

Default behavior: `GraphQLQueryBuilder` creates a `query`.

Set `operationType` for mutations or subscriptions:

```dart
final mutation = GraphQLQueryBuilder(
  name: 'updateBookTitle',
  operationType: GraphQLOperationType.mutation,
  operationName: 'UpdateBookTitle',
  parameters: const [
    QueryParameter('id', 'book-1', type: 'ID', isRequired: true),
    QueryParameter('title', 'Persuasion', type: 'String'),
  ],
  fragments: const [
    QuerySelection(name: 'book', fields: ['id', 'title']),
  ],
);
```

`QueryParameter.type` is only required for `buildDocument()`, because GraphQL operation documents need variable definitions. `buildQuery()` can still use parameters without types for clients that only need the root field selection.

## Validation

The builder validates GraphQL-facing names before emitting output:

- Operation names
- Root field names
- Parameter names
- Selection names and aliases
- Scalar field names

Invalid names throw `ArgumentError`. Missing parameter types in `buildDocument()` throw `StateError`.

## Development

Install dependencies:

```sh
dart pub get
```

Run the full local check:

```sh
dart format --output=none --set-exit-if-changed lib test example
dart analyze
dart test
dart pub publish --dry-run
```

## Project

Website · [gabrimatic.info](https://gabrimatic.info)<br>
Source · [github.com/gabrimatic/graphql_fragment_builder](https://github.com/gabrimatic/graphql_fragment_builder)<br>
Issues · [github.com/gabrimatic/graphql_fragment_builder/issues](https://github.com/gabrimatic/graphql_fragment_builder/issues)
