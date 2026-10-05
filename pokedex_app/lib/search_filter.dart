/// Rows whose [key] text contains [query], ignoring case. An empty or blank
/// query returns [rows] unchanged.
///
/// Matches what the database's `LIKE '%query%'` does for the app's ASCII
/// names, except that `%` and `_` are plain characters here, not wildcards.
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
