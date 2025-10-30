import 'package:flutter/material.dart';

class _SimpleSearchDelegate extends SearchDelegate<String?> {
  _SimpleSearchDelegate({String? initial}) { query = initial ?? ''; }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    close(context, query.trim().isEmpty ? null : query.trim());
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // ممكن تزود اقتراحات لاحقًا
    return const SizedBox.shrink();
  }
}