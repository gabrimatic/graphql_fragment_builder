# Contributing

GraphQL Fragment Builder is a small Dart package, so changes should stay compact and easy to verify.

## Local Setup

Install dependencies:

```sh
dart pub get
```

Run the full check before opening a pull request:

```sh
dart format --output=none --set-exit-if-changed lib test example
dart analyze
dart test
dart pub publish --dry-run
```

## Pull Requests

Keep pull requests focused:

- Explain the behavior change.
- Add or update tests for public API changes.
- Update `README.md` and `CHANGELOG.md` when behavior, setup, or package metadata changes.
- Preserve backwards compatibility unless the breaking change is deliberate and documented.

## API Changes

This package emits GraphQL strings. Small formatting changes can still affect callers, snapshots, and downstream clients.

When changing output behavior, add exact string tests for the generated query or document.
