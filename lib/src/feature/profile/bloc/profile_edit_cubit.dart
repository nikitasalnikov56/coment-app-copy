import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/feature/profile/data/profile_repository.dart';

part 'profile_edit_cubit.freezed.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit({
    required IProfileRepository repository,
  })  : _repository = repository,
        super(const ProfileEditState.initial());
  final IProfileRepository _repository;

  Future<void> editAccount({
    required String password,
    required String name,
    required String email,
    required String phone,
    String? birthDate,
    int cityId = -1,
    int languageId = -1,
    XFile? avatar,
  }) async {
    try {
      emit(const ProfileEditState.loading());

      await _repository.editAccount(
        password: password,
        name: name,
        email: email,
        phone: phone,
        birthDate: birthDate,
        cityId: cityId ,
        languageId: languageId,
        avatar: avatar,
      );
      log('$avatar', name: 'cubit avatar');
      emit(const ProfileEditState.loaded());
    } on RestClientException catch (e) {
      emit(
        ProfileEditState.error(
          message: e.message,
        ),
      );
    } catch (e) {
      emit(
        ProfileEditState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState.initial() = _InitialState;

  const factory ProfileEditState.loading() = _LoadingState;

  const factory ProfileEditState.loaded() = _LoadedState;

  const factory ProfileEditState.error({
    required String message,
  }) = _ErrorState;
}
