/// Rows whose [key] text contains [query], ignoring case. An empty or blank
/// query returns [rows] unchanged.
///
/// This replaces the database's `LIKE '%query%'` search. Results agree with it
/// for every name in the bundled database; the differences are that case is
/// ignored for all letters (SQLite's LIKE only does ASCII), and `%` and `_`
/// are plain characters here, not wildcards.
List<Map<String, dynamic>> filterByName(
  List<Map<String, dynamic>> rows,
  String key,
  String query,
) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return rows;
  return rows
      .where((row) => '${row[key]}'.toLowerCase().contains(needle))
      .toList();
}
