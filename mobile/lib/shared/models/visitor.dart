// mobile/lib/shared/models/visitor.dart
import 'package:json_annotation/json_annotation.dart';

part 'visitor.g.dart';

@JsonSerializable()
class Visitor {
  final int id;
  final String deviceHash;
  final String? email;
  final String? name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visitor({
    required this.id,
    required this.deviceHash,
    this.email,
    this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) => _$VisitorFromJson(json);
  Map<String, dynamic> toJson() => _$VisitorToJson(this);

  String get displayName => name ?? email ?? 'Visiteur anonyme';
  bool get isIdentified => email != null || name != null;
}