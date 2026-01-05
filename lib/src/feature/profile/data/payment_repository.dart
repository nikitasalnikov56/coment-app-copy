import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/feature/profile/models/request/save_payment_card_request.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/auth/data/auth_repository.dart';
import 'package:coment_app/src/feature/profile/data/payment_remote_ds.dart';
import 'package:coment_app/src/feature/profile/models/response/save_payment_card_response.dart';



abstract interface class IPaymentRepository {
  Future<List<SavedPaymentCardResponse>> getPaymentCards();
  Future<void> saveCard(SavePaymentCardRequest request);
  Future<void> deletePaymentCard(int cardId);
}



class PaymentRepositoryImpl implements IPaymentRepository {
  const PaymentRepositoryImpl({
    required this.remoteDS,
    required this.authRepository,
  });

  final PaymentRemoteDs remoteDS;
  final IAuthRepository authRepository;

  @override
  Future<List<SavedPaymentCardResponse>> getPaymentCards() async {
    try {
      return await remoteDS.getPaymentCards();
    } catch (e) {
      if (e is CustomBackendException && e.statusCode == 401) {
        try {
          await authRepository.refreshAccessToken();
          return await remoteDS.getPaymentCards();
        } catch (refreshError) {
          rethrow;
        }
      }
      TalkerLoggerUtil.talker.error('getPaymentCards failed', e);
      rethrow;
    }
  }

  @override
  Future<void> saveCard(SavePaymentCardRequest request) async {
    try {
      await remoteDS.saveCard(request);
    } catch (e) {
      if (e is CustomBackendException && e.statusCode == 401) {
        try {
          await authRepository.refreshAccessToken();
          await remoteDS.saveCard(request);
          return;
        } catch (refreshError) {
          rethrow;
        }
      }
      TalkerLoggerUtil.talker.error('saveCard failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deletePaymentCard(int cardId) async {
    try {
      await remoteDS.deletePaymentCard(cardId);
    } catch (e) {
      if (e is CustomBackendException && e.statusCode == 401) {
        try {
          await authRepository.refreshAccessToken();
          await remoteDS.deletePaymentCard(cardId);
          return;
        } catch (refreshError) {
          rethrow;
        }
      }
      TalkerLoggerUtil.talker.error('deletePaymentCard failed', e);
      rethrow;
    }
  }
}