import 'package:flutter/material.dart';

ImageProvider<Object>? profileImageProvider(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return NetworkImage(value);
}
