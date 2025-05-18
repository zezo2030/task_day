/// Validation utility functions for form fields.
library;

/// Validates that the given [value] is not null or empty.
/// Returns an error message if invalid, otherwise null.
String? validateNotEmpty(String? value, {String fieldName = "This field"}) {
  if (value == null || value.trim().isEmpty) {
    return "$fieldName cannot be empty";
  }
  return null;
}

/// Validates that the given [value] is a valid positive integer.
/// Returns an error message if invalid, otherwise null.
String? validatePositiveInt(String? value, {String fieldName = "Value"}) {
  if (value == null || value.trim().isEmpty) {
    return "$fieldName cannot be empty";
  }
  final intValue = int.tryParse(value.trim());
  if (intValue == null) {
    return "$fieldName must be a number";
  }
  if (intValue <= 0) {
    return "$fieldName must be greater than zero";
  }
  return null;
}

/// Validates that the given [value] does not exceed [maxLength] characters.
/// Returns an error message if invalid, otherwise null.
String? validateMaxLength(
  String? value,
  int maxLength, {
  String fieldName = "This field",
}) {
  if (value != null && value.length > maxLength) {
    return "$fieldName must be at most $maxLength characters";
  }
  return null;
}

/// Validates that the given [value] is a valid number (integer or decimal).
/// Returns an error message if invalid, otherwise null.
String? validateNumber(String? value, {String fieldName = "Value"}) {
  if (value == null || value.trim().isEmpty) {
    return "$fieldName cannot be empty";
  }
  final numValue = num.tryParse(value.trim());
  if (numValue == null) {
    return "$fieldName must be a valid number";
  }
  return null;
}
