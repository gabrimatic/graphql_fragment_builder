# Security

GraphQL Fragment Builder does not make network calls, store credentials, or execute GraphQL requests. It builds strings and variable maps that your app sends through its own GraphQL client.

## Reporting

Report security issues through GitHub Security Advisories:

https://github.com/gabrimatic/graphql_fragment_builder/security/advisories/new

If that is not available, use the contact path on:

https://gabrimatic.info

## Boundaries

Treat schema names, field names, operation names, and parameter names as trusted application code. The package validates GraphQL-facing names, but it does not sanitize arbitrary user input into schema fields.

Use variables for user-provided values. Do not concatenate user input into field names or operation names.
