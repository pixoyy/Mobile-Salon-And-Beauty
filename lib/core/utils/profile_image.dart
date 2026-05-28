import 'dart:convert';

import 'package:flutter/material.dart';

ImageProvider<Object>? profileImageProvider(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  if (value.startsWith('base64:')) {
    final encoded = value.substring('base64:'.length);

    try {
      return MemoryImage(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  return NetworkImage(value);
}