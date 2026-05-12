## 1.1.0

- Added complete GraphQL operation document output with `buildDocument()`.
- Added `GraphQLOperationType` for query, mutation, and subscription documents.
- Added typed variable definitions through `QueryParameter.type` and `isRequired`.
- Added `QuerySelection` for aliases, field arguments, and nested selections.
- Added validation for GraphQL-facing names and empty simple fragments.
- Cleaned generated selection formatting.
- Added CI, contribution guidance, security guidance, and fuller tests.

## 1.0.0

- Initial version of the graphql_fragment_builder package
- Includes QueryFragment, QueryParameter, and GraphQLQueryBuilder classes
- Supports building GraphQL queries with fragments and parameters
