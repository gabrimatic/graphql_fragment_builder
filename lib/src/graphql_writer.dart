void validateGraphQLName(String value, String label) {
  final isValid = RegExp(r'^[_A-Za-z][_0-9A-Za-z]*$').hasMatch(value);

  if (!isValid) {
    throw ArgumentError.value(
      value,
      label,
      'Must be a valid GraphQL name.',
    );
  }
}

void validateGraphQLType(String value, String label) {
  final parser = _GraphQLTypeParser(value.trim());

  if (!parser.parse()) {
    throw ArgumentError.value(
      value,
      label,
      'Must be a valid GraphQL type, such as String, ID!, or [String!]!.',
    );
  }
}

String indentBlock(String value, int levels) {
  final prefix = '  ' * levels;

  return value
      .split('\n')
      .map((line) => line.isEmpty ? line : '$prefix$line')
      .join('\n');
}

class _GraphQLTypeParser {
  _GraphQLTypeParser(this.source);

  final String source;
  int _index = 0;

  bool parse() {
    if (source.isEmpty) {
      return false;
    }

    return _parseType() && _index == source.length;
  }

  bool _parseType() {
    if (_consume('[')) {
      if (!_parseType()) {
        return false;
      }

      if (!_consume(']')) {
        return false;
      }

      _consume('!');
      return true;
    }

    if (!_parseName()) {
      return false;
    }

    _consume('!');
    return true;
  }

  bool _parseName() {
    if (_index >= source.length) {
      return false;
    }

    final first = source.codeUnitAt(_index);
    if (!_isNameStart(first)) {
      return false;
    }

    _index++;

    while (_index < source.length) {
      final codeUnit = source.codeUnitAt(_index);
      if (!_isNameContinue(codeUnit)) {
        break;
      }

      _index++;
    }

    return true;
  }

  bool _consume(String token) {
    if (_index >= source.length || source[_index] != token) {
      return false;
    }

    _index++;
    return true;
  }

  bool _isNameStart(int codeUnit) =>
      codeUnit == 95 ||
      codeUnit >= 65 && codeUnit <= 90 ||
      codeUnit >= 97 && codeUnit <= 122;

  bool _isNameContinue(int codeUnit) =>
      _isNameStart(codeUnit) || codeUnit >= 48 && codeUnit <= 57;
}
