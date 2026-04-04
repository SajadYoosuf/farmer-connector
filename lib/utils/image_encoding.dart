import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Reads image bytes from disk and returns Base64 (no data-URI prefix).
Future<String> imageToBase64(String path) async {
  final bytes = await File(path).readAsBytes();
  return base64Encode(bytes);
}

String _mimeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

/// Value suitable for Firestore `imageUrl` / document fields: embeddable in UI and under one string field.
Future<String> imagePathToDataUri(String path) async {
  final b64 = await imageToBase64(path);
  return 'data:${_mimeForPath(path)};base64,$b64';
}

/// Decodes `data:image/...;base64,...` to bytes; returns null if not a data-image URI or decode fails.
Uint8List? tryDecodeDataImageBytes(String value) {
  if (!value.startsWith('data:image')) return null;
  final comma = value.indexOf(',');
  if (comma < 0 || comma >= value.length - 1) return null;
  try {
    return base64Decode(value.substring(comma + 1));
  } catch (_) {
    return null;
  }
}
