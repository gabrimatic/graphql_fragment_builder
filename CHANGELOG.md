## 1.2.1

- Restored the minimum Dart SDK to 3.5.1. The 3.8.0 floor in 1.2.0 came from dev-only tooling, not the library, which still runs on Dart 3.5.1. Generated GraphQL output and the public API are unchanged.
- Widened the `lints` and `test` dev dependency ranges so the package resolves on Dart 3.5.1 and on current SDKs.
- CI now checks the package on Dart 3.5.1 and the latest stable SDK.

## 1.2.0

- Raised the minimum Dart SDK to 3.8.0. Generated GraphQL output and the public API are unchanged.
- Updated the `test` dev dependency to 1.33 and adopted the current Dart formatter style.
- Tightened the library documentation and simplified `QueryParameter.hasDefinition`.
- Updated CI to `actions/checkout` 7 and `setup-dart` 1.8, with fatal analyzer infos, concurrency, and path filters.
- Grouped Dependabot updates into one monthly pull request per ecosystem.

## 1.1.0

- Added complete GraphQL operation document output with `buildDocument()`.
- Added `GraphQLOperationType` for query, mutation, and subscription documents.
- Added typed variable definitions through `QueryParameter.type` and `isRequired`.
- Added `QuerySelection` for aliases, field arguments, and nested selections.
- Added automatic variable collection across root arguments, nested selections, inline fragments, and named fragment definitions.
- Added `argumentName` so schema argument names can differ from local variable names.
- Added real named fragment support with `GraphQLFragmentDefinition` and `FragmentSpread`.
- Added `InlineFragment` for interface and union selections.
- Added scalar root field support for operation documents without nested selections.
- Added GraphQL variable type validation.
- Added duplicate variable detection to avoid silent variable-map overwrites.
- Expanded tests around nested variables, fragments, scalar roots, invalid types, and duplicate variables.
- Cleaned generated selection formatting.
- Added CI, contribution guidance, security guidance, and fuller tests.

## 1.0.0

- Initial version of the graphql_fragment_builder package
- Includes QueryFragment, QueryParameter, and GraphQLQueryBuilder classes
- Supports building GraphQL queries with fragments and parameters
