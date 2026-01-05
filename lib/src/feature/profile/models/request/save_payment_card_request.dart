// lib/src/feature/profile/models/request/save_payment_card_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'save_payment_card_request.freezed.dart';
part 'save_payment_card_request.g.dart';

@freezed
class SavePaymentCardRequest with _$SavePaymentCardRequest {
  const factory SavePaymentCardRequest({
    required String token,
    required String last4,
    required String brand,
    required String expMonth,
    required String expYear,
    required String cardHolderName, 
  }) = _SavePaymentCardRequest;

  factory SavePaymentCardRequest.fromJson(Map<String, dynamic> json) =>
      _$SavePaymentCardRequestFromJson(json);
}