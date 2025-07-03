// mobile/lib/shared/models/uploaded_file.dart
import 'package:json_annotation/json_annotation.dart';

part 'uploaded_file.g.dart';

@JsonSerializable()
class UploadedFile {
  final String url;
  final String? name;
  final int? size;
  final String? mimeType;
  final DateTime? uploadedAt;

  const UploadedFile({
    required this.url,
    this.name,
    this.size,
    this.mimeType,
    this.uploadedAt,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) => _$UploadedFileFromJson(json);
  Map<String, dynamic> toJson() => _$UploadedFileToJson(this);

  UploadedFile copyWith({
    String? url,
    String? name,
    int? size,
    String? mimeType,
    DateTime? uploadedAt,
  }) {
    return UploadedFile(
      url: url ?? this.url,
      name: name ?? this.name,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  // Getters utilitaires
  bool get isImage => mimeType?.startsWith('image/') ?? false;
  bool get isPdf => mimeType == 'application/pdf';
  bool get isVideo => mimeType?.startsWith('video/') ?? false;
  
  String get fileName => name ?? url.split('/').last;
  
  String get sizeFormatted {
    if (size == null) return 'Unknown size';
    
    final bytes = size!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static UploadedFile demo() {
    return UploadedFile(
      url: 'https://example.com/demo-image.jpg',
      name: 'demo-image.jpg',
      size: 1024 * 512, // 512 KB
      mimeType: 'image/jpeg',
      uploadedAt: DateTime.now(),
    );
  }
}