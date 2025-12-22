// lib/src/feature/profile/bloc/load_documents_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coment_app/src/feature/profile/data/profile_remote_ds.dart';

part 'load_documents_cubit.freezed.dart';

class LoadDocumentsCubit extends Cubit<LoadDocumentsState> {
  final IProfileRemoteDS dataSource;

  LoadDocumentsCubit(this.dataSource)
      : super(const LoadDocumentsState.initial());

  Future<void> uploadDocuments(List<File> files) async {
    emit(const LoadDocumentsState.loading());
    try {
      final urls = await dataSource.uploadDocuments(files);
      emit(LoadDocumentsState.success(urls));
    } catch (e) {
      print(e.toString());
      emit(LoadDocumentsState.failure(e.toString()));
    }
  }
}

@freezed
class LoadDocumentsState with _$LoadDocumentsState {
  const factory LoadDocumentsState.initial() = _Initial;
  const factory LoadDocumentsState.loading() = _Loading;
  const factory LoadDocumentsState.success(List<String> urls) = _Success;
  const factory LoadDocumentsState.failure(String error) = _Failure;
}
