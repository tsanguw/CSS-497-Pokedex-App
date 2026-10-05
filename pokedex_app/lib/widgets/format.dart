/// Formats a stat for display: null becomes an em dash and whole-number
/// doubles drop the trailing ".0" (100.0 -> "100").
String fmtNum(Object? v) {
  if (v == null) return '—';
  if (v is double && v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

const _smallWords = {'and', 'of', 'the', 'or', 'in', 'on', 'a', 'to'};

/// "air-lock" -> "Air Lock", "red and blue" -> "Red and Blue".
/// Database names are lowercase and hyphenated; small words stay lowercase
/// unless they start the name.
String prettyName(Object? raw) {
  final words = (raw ?? '')
      .toString()
      .split(RegExp(r'[-\s]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  return [
    for (var i = 0; i < words.length; i++)
      if (i > 0 && _smallWords.contains(words[i].toLowerCase()))
        words[i].toLowerCase()
      else
        words[i][0].toUpperCase() + words[i].substring(1),
  ].join(' ');
}

/// "porygon-z" -> "Porygon-Z". Pokémon names keep their hyphens, so only
/// each part is capitalized.
String pokemonName(Object? raw) => (raw ?? '')
    .toString()
    .split('-')
    .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
    .join('-');
