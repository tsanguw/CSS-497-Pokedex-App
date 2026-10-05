import 'package:flutter/material.dart';
import 'state_views.dart';

typedef Rows = List<Map<String, dynamic>>;

/// Runs [load] once per search term and shows the rows with [builder].
///
/// The future is held in state and only recreated when [searchQuery] changes,
/// so unrelated rebuilds (theme change, parent setState) don't re-run the
/// database query. While a new query loads, the previous rows stay on screen
/// instead of flashing a spinner.
class SearchResults extends StatefulWidget {
  final String searchQuery;
  final Future<Rows> Function(String searchQuery) load;
  final Widget Function(BuildContext context, Rows rows) builder;
  final String emptyMessage;

  const SearchResults({
    super.key,
    required this.searchQuery,
    required this.load,
    required this.builder,
    required this.emptyMessage,
  });

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late Future<Rows> _future = widget.load(widget.searchQuery);

  @override
  void didUpdateWidget(SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _future = widget.load(widget.searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Rows>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(snapshot.error);
        final rows = snapshot.data;
        if (rows == null) return const LoadingView();
        if (rows.isEmpty) {
          return snapshot.connectionState == ConnectionState.done
              ? EmptyView(widget.emptyMessage)
              : const LoadingView();
        }
        return widget.builder(context, rows);
      },
    );
  }
}
