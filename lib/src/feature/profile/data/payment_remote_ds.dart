import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/feature/profile/models/request/save_payment_card_request.dart';
import 'package:coment_app/src/feature/profile/models/response/save_payment_card_response.dart';


abstract interface class PaymentRemoteDs {
  Future<void> saveCard(SavePaymentCardRequest request);
  Future<List<SavedPaymentCardResponse>> getPaymentCards();
  Future<void> deletePaymentCard(int cardId);
}

class PaymentRemoteDsImpl implements PaymentRemoteDs {
  final IRestClient restClient;

  const PaymentRemoteDsImpl({
    required this.restClient,
  });

  @override
  Future<void> deletePaymentCard(int cardId) async {
    await restClient.delete('payments/cards/$cardId');
  }

@override
Future<List<SavedPaymentCardResponse>> getPaymentCards() async {
  final response = await restClient.get('payments/cards');

   final list = response['data'] as List; // ← безопасно
  return list
      .map((e) => SavedPaymentCardResponse.fromJson(e as Map<String, dynamic>))
      .toList();
}


  @override
  Future<void> saveCard(SavePaymentCardRequest request) async {
    await restClient.post('payments/cards', body: request.toJson());
  }
}
