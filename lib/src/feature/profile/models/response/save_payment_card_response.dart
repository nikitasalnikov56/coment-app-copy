// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_payment_card_response.freezed.dart';
part 'save_payment_card_response.g.dart';

@freezed
class SavedPaymentCardResponse with _$SavedPaymentCardResponse {
  const factory SavedPaymentCardResponse({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'last4') required String last4,
    @JsonKey(name: 'brand') required String brand,
    @JsonKey(name: 'expMonth') required String expMonth,
    @JsonKey(name: 'expYear') required String expYear,
    @JsonKey(name: 'isDefault') required bool isDefault,
    @JsonKey(name: 'createdAt') required String createdAt, // если backend возвращает
     @JsonKey(name: 'card_holder_name') required String cardHolderName,
  }) = _SavedPaymentCardResponse;

  factory SavedPaymentCardResponse.fromJson(Map<String, dynamic> json) 
      => _$SavedPaymentCardResponseFromJson(json);
  
      
}