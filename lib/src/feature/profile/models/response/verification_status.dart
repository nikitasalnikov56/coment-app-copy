import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_status.freezed.dart';
part 'verification_status.g.dart';

@freezed
class VerificationStatus with _$VerificationStatus {
  const factory VerificationStatus({
    required String status, // approved, pending, rejected, not_requested
    String? message,
    int? companyId,
  }) = _VerificationStatus;

  factory VerificationStatus.fromJson(Map<String, dynamic> json) =>
      _$VerificationStatusFromJson(json);
}
