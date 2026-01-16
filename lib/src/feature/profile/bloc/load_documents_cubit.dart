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

  Future<void> fetchDocuments() async {
    emit(const LoadDocumentsState.loading());
    try {
      final urls = await dataSource.getMyDocuments();
      emit(LoadDocumentsState.loaded(urls));
    } catch (e) {
      emit(LoadDocumentsState.failure(e.toString()));
    }
  }

  Future<void> uploadDocuments(
    List<File> files,
    // int companyId,
  ) async {
    emit(const LoadDocumentsState.loading());
    try {
      final urls = await dataSource.uploadDocuments(
        files,
        // companyId,
      );
      emit(LoadDocumentsState.success(urls));
    } catch (e) {
      emit(LoadDocumentsState.failure(e.toString()));
    }
  }

  Future<void> deleteDocument(String url) async {
    emit(const LoadDocumentsState.loading());
    try {
      await dataSource.deleteDocument(url);
      // После успешного удаления — перезагружаем список
      await fetchDocuments();
    } catch (e) {
      emit(LoadDocumentsState.failure(e.toString()));
    }
  }
}

@freezed
class LoadDocumentsState with _$LoadDocumentsState {
  const factory LoadDocumentsState.initial() = _Initial;
  const factory LoadDocumentsState.loading() = _Loading;
  const factory LoadDocumentsState.success(List<String> urls) = _Success;
  const factory LoadDocumentsState.loaded(List<String> urls) = _Loaded;
  const factory LoadDocumentsState.failure(String error) = _Failure;
}
