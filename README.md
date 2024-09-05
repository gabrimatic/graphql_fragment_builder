# GraphQL Fragment Builder

A Flutter package that enables you to build flexible and type-safe GraphQL fragments and queries with a single function call.

## How to use it?

**1. Add the package to pubspec.yaml dependency:**

```yaml
dependencies:
  graphql_fragment_builder: ^1.0.0
```

**2. Import package:**

```dart
import 'package:graphql_fragment_builder/graphql_fragment_builder.dart';
```

**3. Create your fragments:**

```dart
class BookDetailsFragment extends QueryFragment with SimpleQueryFragment {
  @override
  String get objectName => 'bookDetails';

  @override
  List<String> get fields => [
        'title',
        'author',
        'publicationYear',
        'genre',
      ];
}
```

**4. Build your query:**

```dart
final query = GraphQLQueryBuilder(
  name: 'getBooksByAuthor',
  parameters: [
    QueryParameter('authorName', 'Jane Austen'),
    QueryParameter('limit', 5),
  ],
  fragments: [BookDetailsFragment()],
);

debugPrint(query.buildQuery());
debugPrint(query.variables);
```

**Output:**

```dart
getBooksByAuthor(authorName: $authorName, limit: $limit) {
  bookDetails {
    title
    author
    publicationYear
    genre
  }
}

{authorName: Jane Austen, limit: 5}
```

## Advanced Usage

You can combine multiple fragments in a single query for more complex operations:

```dart
class AuthorDetailsFragment extends QueryFragment with SimpleQueryFragment {
  @override
  String get objectName => 'authorDetails';

  @override
  List<String> get fields => [
        'name',
        'birthYear',
        'nationality',
      ];
}

final complexQuery = GraphQLQueryBuilder(
  name: 'getAuthorWithBooks',
  parameters: [
    QueryParameter('authorId', '123'),
  ],
  fragments: [AuthorDetailsFragment(), BookDetailsFragment()],
);
```

**Output:**
```dart
getAuthorWithBooks(authorId: $authorId) {
  authorDetails {
    name
    birthYear
    nationality
  }
  bookDetails {
    title
    author
    publicationYear
    genre
  }
}

{authorId: 123}
```

This flexibility allows you to build complex queries while maintaining readability and type safety.

## Features

- **Pattern-matching approach:** Build GraphQL queries using a flexible, type-safe method.
- **Improved readability:** Structured query building enhances code clarity.
- **Easy maintenance:** Modular design allows for simple updates and extensions.
- **Fragment support:** Create reusable query fragments for efficient query composition.
- **Parameter handling:** Easily include and manage query parameters.

## Developer
By [Hossein Yousefpour](https://gabrimatic.info "Hossein Yousefpour")

&copy; All rights reserved.

## Donate
<a href="https://www.buymeacoffee.com/gabrimatic" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Book" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>