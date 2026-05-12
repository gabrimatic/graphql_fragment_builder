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
