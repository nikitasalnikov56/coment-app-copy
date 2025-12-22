import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/choose_image_bs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coment_app/src/feature/profile/bloc/load_documents_cubit.dart';

@RoutePage()
class LoadDocumentsPage extends StatelessWidget {
  const LoadDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoadDocumentsCubit(context.repository.profileRemoteDS),
      child: const LoadingDocumentWidget(),
    );
  }
}

class LoadingDocumentWidget extends StatefulWidget {
  const LoadingDocumentWidget({super.key});

  @override
  State<LoadingDocumentWidget> createState() =>
      _LoadingDocumentStateWidgetState();
}

class _LoadingDocumentStateWidgetState extends State<LoadingDocumentWidget> {
  final List<File> _imageFiles = [];
  final List<File> _documentFiles = [];
  static const int _maxTotalFiles = 10;
  final ImagePicker imagePicker = ImagePicker();
  bool _isSubmitted = false;

  bool get _canAddMore =>
      _imageFiles.length + _documentFiles.length < _maxTotalFiles;

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result?.files.singleOrNull != null && _canAddMore) {
        final path = result!.files.single.path;
        if (path != null) {
          setState(() {
            _documentFiles.add(File(path));
          });
        }
      }
    } catch (e) {
      // Логирование ошибки (опционально)
      debugPrint('FilePicker error: $e');
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось выбрать файл: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _imageFiles.removeAt(index));
  }

  void _removeDocument(int index) {
    setState(() => _documentFiles.removeAt(index));
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: AppColors.mainColor),
              title: Text(context.localized.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                ChooseImageBottomSheet.show(
                  context,
                  avatar: false,
                  image: (File? file) {
                    if (file != null && _canAddMore) {
                      setState(() => _imageFiles.add(file));
                    }
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner,
                  color: AppColors.mainColor),
              title: const Text('PDF, DOC, DOCX'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(String path) {
    return p.basename(path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoadDocumentsCubit, LoadDocumentsState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (urls) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.localized.documentsSentForReview),
                backgroundColor: Colors.green,
              ),
            );
            // _imageFiles.clear();
            // _documentFiles.clear();
            // setState(() {});
            setState(() {
              _isSubmitted = true;
            });
          },
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (BuildContext context, LoadDocumentsState state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: context.localized.loadDocuments,
            shape: const Border(
                bottom: BorderSide(color: AppColors.dividerColor, width: 0.5)),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                // Изображения — GridView
                if (_imageFiles.isNotEmpty)
                  Expanded(
                    flex: (_imageFiles.length > 3) ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                        ),
                        itemCount: _imageFiles.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFiles[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              if (_isSubmitted)
                               const  Align(
                                  alignment: Alignment.bottomRight,
                                  child:  Padding(
                                    padding: EdgeInsets.only(right: 8.0, bottom: 8),
                                    child: Icon(Icons.check_circle,
                                        color: AppColors.green, size: 20),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                // Документы — ListView
                if (_documentFiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 100 * _documentFiles.length.toDouble(),
                      child: ListView.builder(
                        itemCount: _documentFiles.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.insert_drive_file),
                                title: Text(_getDisplayName(
                                    _documentFiles[index].path)),
                                trailing:
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (_isSubmitted)
                                           const Icon(Icons.check_circle,
                                            color: AppColors.green, size: 20),
                                          IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () => _removeDocument(index),
                                            ),
                                        ],
                                      ),
                                    )
                                    ,
                              ),
                            
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                // Кнопка "+"
                if (_canAddMore)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: _showAddOptions,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mainColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.add,
                              color: AppColors.mainColor, size: 32),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Кнопка отправки

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomButton(
                    onPressed: (_imageFiles.isEmpty && _documentFiles.isEmpty)
                        ? null
                        : () {
                            final allFiles = [
                              ..._imageFiles,
                              ..._documentFiles
                            ];
                            context
                                .read<LoadDocumentsCubit>()
                                .uploadDocuments(allFiles);
                          },
                    style: const ButtonStyle(),
                    child: Text(context.localized.send),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
