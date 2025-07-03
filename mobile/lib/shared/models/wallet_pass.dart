// mobile/lib/shared/models/wallet_pass.dart
import 'package:json_annotation/json_annotation.dart';
import 'uploaded_file.dart';
import 'card.dart';

part 'wallet_pass.g.dart';

@JsonSerializable()
class WalletPass {
  final int id;
  final String passTypeIdentifier;
  final String serialNumber;
  final String? passUrl;
  final UploadedFile? qrCodeMedia;
  final PassStatus status;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final Card card;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletPass({
    required this.id,
    required this.passTypeIdentifier,
    required this.serialNumber,
    this.passUrl,
    this.qrCodeMedia,
    required this.status,
    this.generatedAt,
    this.expiresAt,
    required this.card,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletPass.fromJson(Map<String, dynamic> json) => _$WalletPassFromJson(json);
  Map<String, dynamic> toJson() => _$WalletPassToJson(this);

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isValid => status == PassStatus.active && !isExpired;
  bool get canDownload => passUrl != null && isValid;

  String get statusDisplay {
    switch (status) {
      case PassStatus.pending:
        return 'En cours de génération';
      case PassStatus.active:
        return isExpired ? 'Expiré' : 'Actif';
      case PassStatus.revoked:
        return 'Révoqué';
      case PassStatus.error:
        return 'Erreur';
    }
  }

  WalletPass copyWith({
    String? passTypeIdentifier,
    String? serialNumber,
    String? passUrl,
    UploadedFile? qrCodeMedia,
    PassStatus? status,
    DateTime? generatedAt,
    DateTime? expiresAt,
    Card? card,
  }) {
    return WalletPass(
      id: id,
      passTypeIdentifier: passTypeIdentifier ?? this.passTypeIdentifier,
      serialNumber: serialNumber ?? this.serialNumber,
      passUrl: passUrl ?? this.passUrl,
      qrCodeMedia: qrCodeMedia ?? this.qrCodeMedia,
      status: status ?? this.status,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      card: card ?? this.card,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static WalletPass demo() {
    final now = DateTime.now();
    return WalletPass(
      id: 1,
      passTypeIdentifier: 'pass.com.showme.business-card',
      serialNumber: 'DEMO-${now.millisecondsSinceEpoch}',
      passUrl: 'https://example.com/passes/demo.pkpass',
      qrCodeMedia: UploadedFile.demo(),
      status: PassStatus.active,
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 365)), // Expire dans 1 an
      card: Card.demo(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

@JsonEnum()
enum PassStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('revoked')
  revoked,
  @JsonValue('error')
  error,
}