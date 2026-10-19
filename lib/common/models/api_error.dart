import 'package:get/get.dart';

/// A single field/topic level error.
///
/// The API expresses these in two shapes, both of which collapse into this:
///   `"errors": [{"code": "not-found", "message": "Email not found!"}]`
///   `"errors": {"image": ["Image is required"], "name": ["The name field is required."]}`
class FieldError {
  final String field;
  final String message;

  const FieldError(this.field, this.message);

  @override
  String toString() => '$field: $message';
}

/// Normalised view of any non successful API response.
///
/// Every error body the API returns fits one of four shapes:
///
/// 1. envelope + list  `{identical_code, message, content: null, errors: [{code, message}]}`
/// 2. envelope + map   `{identical_code, message, content: null, errors: {field: [message]}}`
/// 3. bare validation  `{message, errors: {field: [message]}}`
/// 4. bare message     `{message}`
///
/// Plus the non JSON cases: HTML/empty bodies, and the client side
/// timeout/socket failures the [ApiClient] reports as status 0 or 1.
///
/// [message] is always safe to show to the user, [fieldErrors] is what to bind
/// to inputs on a form.
class ApiError {
  /// HTTP status, or 0/1 for a client side network failure.
  final int statusCode;

  /// Resolved, user facing message. Never empty.
  final String message;

  /// Per field / per topic errors, in the order the API sent them.
  final List<FieldError> fieldErrors;

  /// Backend error identifier, e.g. `unprocessable_entity_422`. Null on the bare shapes.
  final String? identicalCode;

  const ApiError({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const [],
    this.identicalCode,
  });

  static const String noInternetMessage = 'Connection to API server failed due to internet connection';

  factory ApiError.fromResponse(Response response) {
    final int status = response.statusCode ?? 0;
    final dynamic body = response.body;

    if (body is! Map) {
      return ApiError(statusCode: status, message: _fallbackMessage(status, response.statusText));
    }

    final List<FieldError> fieldErrors = _parseFieldErrors(body['errors']);
    final String? topMessage = _clean(body['message']);

    // On the list shape the top level message is generic ("Not found", "Permission denied")
    // while errors[0].message carries the real reason, so that one wins.
    final bool preferFirstFieldError = body['errors'] is List && fieldErrors.isNotEmpty;

    final String message = (preferFirstFieldError ? fieldErrors.first.message : topMessage)
        ?? (fieldErrors.isNotEmpty ? fieldErrors.first.message : null)
        ?? _fallbackMessage(status, response.statusText);

    return ApiError(
      statusCode: status, message: message, fieldErrors: fieldErrors,
      identicalCode: body['identical_code']?.toString(),
    );
  }

  static List<FieldError> _parseFieldErrors(dynamic errors) {
    final List<FieldError> list = [];
    if (errors is List) {
      for (final dynamic error in errors) {
        if (error is Map) {
          final String? message = _clean(error['message']);
          if (message != null) {
            list.add(FieldError(error['code']?.toString() ?? '', message));
          }
        } else if (error != null) {
          list.add(FieldError('', error.toString()));
        }
      }
    } else if (errors is Map) {
      errors.forEach((key, value) {
        if (value is List) {
          for (final dynamic message in value) {
            if (_clean(message) != null) {
              list.add(FieldError(key.toString(), _clean(message)!));
            }
          }
        } else if (_clean(value) != null) {
          list.add(FieldError(key.toString(), _clean(value)!));
        }
      });
    }
    return list;
  }

  /// Laravel appends "(and 2 more errors)" to the summary message; the field
  /// list already carries those, so drop the noise.
  static String? _clean(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().replaceAll(RegExp(r'\s*\(and \d+ more errors?\)\s*$'), '').trim();
    return text.isEmpty ? null : text;
  }

  static String _fallbackMessage(int status, String? statusText) {
    if (status == 0 || status == 1) return _tr('no_internet_connection', noInternetMessage);
    if (status == 401) return _tr('unauthorized_access', 'Your session has expired. Please sign in again.');
    if (status == 403) return _tr('permission_denied', 'Permission denied');
    if (status == 404) return _tr('not_found', 'Not found');
    if (status >= 500) return _tr('server_error', 'Server error, please try again later');
    final String? text = _clean(statusText);
    return text ?? _tr('something_went_wrong', 'Something went wrong, please try again');
  }

  /// `.tr` echoes the key back when there is no translation for it, so fall
  /// back to English instead of showing a raw key to the user.
  static String _tr(String key, String fallback) {
    final String value = key.tr;
    return value == key ? fallback : value;
  }

  /// Token missing, expired or rotated by another login — the session is gone.
  bool get isUnauthorized => statusCode == 401;

  /// Request never reached the server (no connection, DNS or timeout).
  bool get isNetworkError => statusCode == 0 || statusCode == 1;

  bool get isValidationError => statusCode == 422 || fieldErrors.isNotEmpty;

  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  /// First message reported for [field], e.g. `error.forField('image')`.
  /// Matches the `errors` map keys and the `errors[].code` values.
  String? forField(String field) {
    for (final FieldError error in fieldErrors) {
      if (error.field == field) return error.message;
    }
    return null;
  }

  /// One message per field, ready to feed a form's error state.
  Map<String, String> get fieldMessages {
    final Map<String, String> map = {};
    for (final FieldError error in fieldErrors) {
      if (error.field.isNotEmpty) {
        map.putIfAbsent(error.field, () => error.message);
      }
    }
    return map;
  }

  /// Every message joined, for the rare screen that wants to list them all.
  String get allMessages => fieldErrors.isEmpty ? message : fieldErrors.map((e) => e.message).join('\n');

  @override
  String toString() => 'ApiError($statusCode, $message, fields: $fieldErrors)';
}

extension ApiErrorResponse on Response {
  /// Normalised error for this response, for the `handleError: false` call
  /// sites that need the field list rather than just a snackbar.
  ApiError get apiError => ApiError.fromResponse(this);

  bool get isSuccessful => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
