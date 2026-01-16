// lib/src/feature/profile/bloc/verification_cubit.dart
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:coment_app/src/feature/companies/models/company_dto.dart';
import 'package:coment_app/src/feature/profile/data/profile_repository.dart';
import 'package:coment_app/src/feature/profile/models/response/verification_response.dart';

part 'verification_cubit.freezed.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final IProfileRepository _repository;

  VerificationCubit(this._repository) : super(const VerificationState.initial());

  Future<void> fetchMyCompanies() async {
    emit(const VerificationState.loading());
    try {
      final companies = await _repository.getMyCompanies();
      emit(VerificationState.companiesLoaded(companies: companies));
    } catch (e) {
      emit(VerificationState.failure(error: e.toString()));
    }
  }

  Future<void> createVerificationRequest({
    required int companyId,
    required List<String> documentUrls,
  }) async {
    emit(const VerificationState.loading());
    try {
      final response = await _repository.createVerificationRequest(
        companyId: companyId,
        documentUrls: documentUrls,
      );
      emit(VerificationState.success(request: response));
    } catch (e) {
      emit(VerificationState.failure(error: e.toString()));
    }
  }
}

@freezed
class VerificationState with _$VerificationState {
  const factory VerificationState.initial() = _Initial;
  const factory VerificationState.loading() = _Loading;
  const factory VerificationState.companiesLoaded({required List<ProductDTO> companies}) = _CompaniesLoaded;
  const factory VerificationState.success({required VerificationResponse request}) = _Success;
  const factory VerificationState.failure({required String error}) = _Failure;
}