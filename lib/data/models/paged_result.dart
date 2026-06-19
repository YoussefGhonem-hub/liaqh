/// A page of results from a server-side paginated endpoint.
class PagedResult<T> {
  final List<T> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  const PagedResult({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });

  bool get hasNextPage => pageNumber < totalPages;

  /// Parses a backend `PaginatedList` JSON envelope. Falls back gracefully if
  /// the endpoint still returns a bare list (pageNumber/totalPages = 1).
  factory PagedResult.fromJson(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is List) {
      final items = data
          .map((j) => fromJson(j as Map<String, dynamic>))
          .toList();
      return PagedResult(
        items: items,
        pageNumber: 1,
        totalPages: 1,
        totalCount: items.length,
      );
    }
    final map = data as Map<String, dynamic>;
    final rawItems = map['items'] as List? ?? [];
    return PagedResult(
      items: rawItems
          .map((j) => fromJson(j as Map<String, dynamic>))
          .toList(),
      pageNumber: map['pageNumber'] ?? 1,
      totalPages: map['totalPages'] ?? 1,
      totalCount: map['totalCount'] ?? rawItems.length,
    );
  }
}
