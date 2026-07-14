# GraphQL Fragment Builder

[![Dart CI](https://github.com/gabrimatic/graphql_fragment_builder/actions/workflows/dart.yml/badge.svg)](https://github.com/gabrimatic/graphql_fragment_builder/actions/workflows/dart.yml)
[![pub package](https://img.shields.io/pub/v/graphql_fragment_builder.svg)](https://pub.dev/packages/graphql_fragment_builder)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

GraphQL Fragment Builder is a small Dart package for building GraphQL selection sets, variables, fragments, and operation documents without assembling strings by hand. It keeps the query shape close to Dart code, while still producing plain GraphQL strings and variable maps for any client.

## Quick Start

Runtime: **Dart >= 3.5.1**.

Add the package:

```yaml
dependencies:
  graphql_fragment_builder: ^1.1.0
```

Build a document:

```dart
import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';

const bookFields = GraphQLFragmentDefinition(
  name: 'BookFields',
  typeCondition: 'Book',
  fields: ['id', 'title', 'publicationYear'],
);

final query = GraphQLQueryBuilder(
  name: 'booksByAuthor',
  operationName: 'BooksByAuthor',
  parameters: const [
    QueryParameter('authorName', 'Jane Austen', type: 'String', isRequired: true),
    QueryParameter('bookLimit', 5, argumentName: 'limit', type: 'Int'),
  ],
  fragments: const [
    FragmentSpread('BookFields'),
    QuerySelection(
      name: 'reviews',
      parameters: [
        QueryParameter('reviewLimit', 3, argumentName: 'limit', type: 'Int'),
      ],
      fields: ['rating', 'body'],
    ),
  ],
  fragmentDefinitions: const [bookFields],
);

print(query.buildDocument());
print(query.variables);
```

Output:

```graphql
query BooksByAuthor($authorName: String!, $bookLimit: Int, $reviewLimit: Int) {
  booksByAuthor(authorName: $authorName, limit: $bookLimit) {
    ...BookFields
    reviews(limit: $reviewLimit) {
      rating
      body
    }
  }
}

fragment BookFields on Book {
  id
  title
  publicationYear
}
```

```dart
{authorName: Jane Austen, bookLimit: 5, reviewLimit: 3}
```

## What It Builds

| Method | Output | Use it when |
| --- | --- | --- |
| `buildQuery()` | A root field selection | Your GraphQL client wraps the operation for you |
| `buildDocument()` | A full `query`, `mutation`, or `subscription` document | You send the document string yourself |
| `variables` | A merged variable map from the whole selection tree | Your client sends variables separately |

## Variables And Arguments

`QueryParameter.name` is the GraphQL variable name. By default it is also the schema argument name.

Use `argumentName` when the schema argument and local variable should differ:

```dart
QueryParameter('reviewLimit', 3, argumentName: 'limit', type: 'Int')
```

That emits:

```graphql
limit: $reviewLimit
```

Variables are collected from the root field, nested selections, inline fragments, and named fragment definitions. Duplicate variable names are allowed only when they resolve to the same value and compatible metadata; conflicting duplicates throw `ArgumentError`.

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

Use `QuerySelection` when a field needs arguments, an alias, or nested selections:

```dart
const QuerySelection(
  name: 'author',
  alias: 'primaryAuthor',
  fields: ['name'],
);
```

Use `InlineFragment` for interfaces and unions:

```dart
const InlineFragment(
  typeCondition: 'Book',
  fields: ['title'],
);
```

Use `GraphQLFragmentDefinition` and `FragmentSpread` for reusable named fragments:

```dart
const bookFields = GraphQLFragmentDefinition(
  name: 'BookFields',
  typeCondition: 'Book',
  fields: ['id', 'title'],
);

const spread = FragmentSpread('BookFields');
```

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

`QueryParameter.type` is required for `buildDocument()`, because GraphQL operation documents need variable definitions. `buildQuery()` can still use parameters without types for clients that only need the root field selection.

## Validation

The builder validates GraphQL-facing names and variable types before emitting output:

- Operation names
- Root field names
- Argument and variable names
- Selection names and aliases
- Scalar field names
- GraphQL variable types such as `String`, `ID!`, and `[String!]!`
- Named fragment definitions and spreads

Invalid names and conflicting variables throw `ArgumentError`. Missing parameter types in `buildDocument()` throw `StateError`.

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
