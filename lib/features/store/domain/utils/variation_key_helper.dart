String canonicalVariationType(String value) {
  return value.replaceAll(RegExp(r'\s+'), '');
}

String variationRequestKey(String value) {
  return canonicalVariationType(value).replaceAll('.', '_');
}
