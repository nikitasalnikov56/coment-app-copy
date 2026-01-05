// lib/src/feature/profile/bloc/payment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coment_app/src/feature/profile/data/payment_remote_ds.dart';
import 'package:coment_app/src/feature/profile/models/request/save_payment_card_request.dart';
import 'package:coment_app/src/feature/profile/models/response/save_payment_card_response.dart';

part 'payment_cubit.freezed.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRemoteDs dataSource;

  PaymentCubit(this.dataSource) : super(const PaymentState.initial());

  Future<void> loadCards() async {
    emit(const PaymentState.loading());
    try {
      final cards = await dataSource.getPaymentCards();
      emit(PaymentState.loaded(cards));
    } catch (e) {
      emit(PaymentState.failure(e.toString()));
    }
  }

  Future<void> saveCard(SavePaymentCardRequest request) async {
    emit(const PaymentState.loading());
    try {
      await dataSource.saveCard(request);
      // Перезагружаем список после сохранения
      await loadCards();
      // emit(const PaymentState.success());
    } catch (e) {
      emit(PaymentState.failure(e.toString()));
    }
  }

  Future<void> deleteCard(int cardId) async {
    emit(const PaymentState.loading());
    try {
      await dataSource.deletePaymentCard(cardId);
      // Перезагружаем список после удаления
      await loadCards();
    } catch (e) {
      emit(PaymentState.failure(e.toString()));
    }
  }
}

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;
  const factory PaymentState.loading() = _Loading;
  const factory PaymentState.success() = _Success;
  const factory PaymentState.loaded(List<SavedPaymentCardResponse> cards) = _Loaded;
  const factory PaymentState.failure(String error) = _Failure;
}