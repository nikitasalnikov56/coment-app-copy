
import 'package:coment_app/src/feature/app/bloc/app_bloc.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/profile/data/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required IProfileRepository repository,
    required AppBloc appBloc,
    required String password
  })  : _repository = repository,
        _appBloc = appBloc,
        _password=password,
        super(const ProfileState.initial());

  final IProfileRepository _repository;
  final AppBloc _appBloc;
  final String _password;

  Future<void> getProfile() async {
    try {
      emit(const ProfileState.loading());

      if (!_appBloc.isAuthenticated) {
        emit(const ProfileState.notAuthorized());
        return;
      }

      final result = await _repository.profileData();

      if (isClosed) return;

      emit(ProfileState.loaded(userDTO: result));
    } catch (e) {
      if (_isUnauthorizedError(e)) {
        emit(const ProfileState.notAuthorized());
      } else {
        emit(ProfileState.error(message: e.toString()));
      }
    }
  }


   Future<void> deleteProfile() async {
    emit(const ProfileState.loading());

    final result = await _repository.deleteAccount(password: _password);

    result.when(
      success: (user) {
        emit(const ProfileState.deletedState());
      },
      failure: (e) {
        e.maybeWhen(
          orElse: () {
            emit(
              ProfileState.error(
                message: e.msg ?? 'Unhandled Exeption in ProfileCubit',
              ),
            );
          },
        );
      },
    );
  }

  bool _isUnauthorizedError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _InitialState;
  const factory ProfileState.notAuthorized() = _NotAuthorizedState;
  const factory ProfileState.loading() = _LoadingState;
  const factory ProfileState.deletedState() = _DeletedState;
  const factory ProfileState.loaded({required UserDTO userDTO}) = _LoadedState;
  const factory ProfileState.error({required String message}) = _ErrorState;
}
