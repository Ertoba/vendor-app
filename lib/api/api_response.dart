import 'package:get/get.dart';

/// Helpers for the standard API envelope.
///
/// Every `api/v1` endpoint now wraps its payload:
/// ```json
/// {"identical_code": "default_200", "message": "Successfully fetched", "content": …, "errors": []}
/// ```
/// and list endpoints put the rows and the page info inside that payload:
/// ```json
/// "content": {"data": [ … ], "pagination": {"current_page": 1, "last_page": 1, "per_page": 25, "total": 12, "from": 1, "to": 12}}
/// ```
///
/// Everything here falls back to the pre envelope shape when the envelope is
/// absent, so a screen can be migrated on its own without waiting for the rest.
extension ApiResponseData on Response {
  bool get _isEnveloped => body is Map && (body as Map).containsKey('identical_code') && (body as Map).containsKey('content');

  /// The payload — `content` when enveloped, the raw body otherwise.
  dynamic get content => _isEnveloped ? body['content'] : body;

  /// The payload as an object, or an empty map when the endpoint sent none.
  Map<String, dynamic> get contentMap {
    final dynamic data = content;
    return data is Map<String, dynamic> ? data : (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});
  }

  /// The rows of a list endpoint: `content.data`, or the payload itself back
  /// when the endpoint still returns a bare array.
  List<dynamic> get dataList {
    final dynamic data = content;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return const [];
  }

  /// Page info of a list endpoint, null on endpoints that don't paginate.
  PaginationModel? get pagination {
    final dynamic data = content;
    if (data is Map && data['pagination'] is Map) {
      return PaginationModel.fromJson(Map<String, dynamic>.from(data['pagination']));
    }
    return null;
  }

  /// The envelope's own message, e.g. "Successfully fetched" — the success
  /// counterpart of `statusText`.
  String? get apiMessage => body is Map ? body['message']?.toString() : null;

  /// What actually happened, for showing to the user after a write.
  ///
  /// Endpoints that report an outcome put it in the payload
  /// (`content.message`: "Serviceman updated successfully") while the envelope
  /// keeps its generic "Successfully fetched" — so the payload's message wins
  /// and [apiMessage] is only the fallback for endpoints that send none.
  String? get successMessage {
    final dynamic data = content;
    if (data is Map) {
      final String text = (data['message'] ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return apiMessage;
  }
}

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  const PaginationModel({
    required this.currentPage, required this.lastPage, required this.perPage,
    required this.total, this.from, this.to,
  });

  PaginationModel.fromJson(Map<String, dynamic> json)
      : currentPage = _toInt(json['current_page']) ?? 1,
        lastPage = _toInt(json['last_page']) ?? 1,
        perPage = _toInt(json['per_page']) ?? 0,
        total = _toInt(json['total']) ?? 0,
        from = _toInt(json['from']),
        to = _toInt(json['to']);

  bool get hasNextPage => currentPage < lastPage;

  static int? _toInt(dynamic value) => value == null ? null : (value is int ? value : int.tryParse(value.toString()));

  @override
  String toString() => 'PaginationModel(page $currentPage/$lastPage, per page $perPage, total $total)';
}
