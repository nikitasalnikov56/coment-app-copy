import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/choose_image_bs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coment_app/src/feature/profile/bloc/load_documents_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coment_app/src/feature/profile/bloc/verification_cubit.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';

@RoutePage()
class LoadDocumentsPage extends StatelessWidget {
  const LoadDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LoadDocumentsCubit(context.repository.profileRemoteDS)
                ..fetchDocuments(),
        ),
        BlocProvider(
          create: (context) =>
              VerificationCubit(context.repository.profileRepository),
        ),
      ],
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
  List<String> _existingDocuments = [];
  static const int _maxTotalFiles = 10;
  final ImagePicker imagePicker = ImagePicker();
  bool _isSubmitted = false;

  List<ProductDTO> _myCompanies = []; // Список компаний владельца
  ProductDTO? _selectedCompany; // Выбранная компания

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

  void _selectCompany(ProductDTO company) {
    setState(() {
      _selectedCompany = company;
    });
  }

  String _getDisplayName(String path) {
    return p.basename(path);
  }

  @override
  void initState() {
    super.initState();
    context.read<VerificationCubit>().fetchMyCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerificationCubit, VerificationState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (request) {
            setState(() {
              _imageFiles.clear();
              _documentFiles.clear();
              _selectedCompany = null;
              _isSubmitted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Запрос на верификацию отправлен!',
                ),
                backgroundColor: AppColors.green,
              ),
            );
            // Также можно обновить список документов, если нужно
            // context.read<LoadDocumentsCubit>().fetchDocuments();
          },
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка верификации: $error'),
                backgroundColor: AppColors.red2,
              ),
            );
          },
          orElse: () {},
        );
        state.maybeWhen(
          companiesLoaded: (companies) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _myCompanies = companies;
                });
              }
            });
          },
          orElse: () {},
        );
        // Обновление списка компаний
        // if (state is VerificationState.companiesLoaded) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) {
        //       setState(() {
        //         _myCompanies = state.companies;
        //       });
        //     }
        //   });
        // }
      },
      child: BlocConsumer<LoadDocumentsCubit, LoadDocumentsState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (urls) {
              if (_selectedCompany != null) {
                context.read<VerificationCubit>().createVerificationRequest(
                      companyId: _selectedCompany!.id!,
                      documentUrls: urls,
                    );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.localized.documentsSentForReview),
                  backgroundColor: AppColors.green,
                ),
              );
              _imageFiles.clear();
              _documentFiles.clear();
              setState(() {
                _isSubmitted = true;
              });
              context.read<LoadDocumentsCubit>().fetchDocuments();
            },
            loaded: (urls) {
              setState(() {
                _existingDocuments = urls;
                _isSubmitted = false; // сброс флага отправки
              });
            },
            failure: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка: $error'),
                  backgroundColor: AppColors.red2,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (BuildContext context, LoadDocumentsState state) {
          final verificationState = context.watch<VerificationCubit>().state;

          final isCompaniesLoading = verificationState.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          final bool isVerificationLoading = verificationState.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            appBar: CustomAppBar(
              title: context.localized.loadDocuments,
              shape: const Border(
                  bottom:
                      BorderSide(color: AppColors.dividerColor, width: 0.5)),
              actions: [
                if (_canAddMore)
                  GestureDetector(
                    onTap: _showAddOptions,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        border: Border.all(color: AppColors.mainColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Добавить файл',
                        style: AppTextStyles.fs14w500.copyWith(
                          color: AppColors.grey2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            bottomSheet: SendButtonWidget(
              imageFiles: _imageFiles,
              documentFiles: _documentFiles,
              isCompaniesLoading: isCompaniesLoading,
              isVerificationLoading: isVerificationLoading,
              selectedCompany: _selectedCompany,
            ),
            body: Column(
              children: [
                // === Секция: Выбор компании ===

                if (_myCompanies.isEmpty && !isCompaniesLoading)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: Center(
                      child: Text(
                        'У вас пока нет компаний.',
                        style: AppTextStyles.fs14w500.copyWith(
                          color: AppColors.greyTextColor2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (!isCompaniesLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(24),
                        Text(
                          'Выберите компанию для верификации',
                          style: AppTextStyles.fs14w600
                              .copyWith(color: AppColors.greyTextColor2),
                        ),
                        const Gap(8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _myCompanies.length,
                            itemBuilder: (context, index) {
                              final company = _myCompanies[index];
                              final isSelected =
                                  _selectedCompany?.id == company.id;
                              return GestureDetector(
                                onTap: () => _selectCompany(company),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.mainColor
                                        : AppColors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.mainColor
                                          : AppColors.borderTextField,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      company.name ?? 'Без названия',
                                      style: AppTextStyles.fs12w500.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.greyTextColor2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Gap(18),
                      ],
                    ),
                  ),
                const Divider(
                  height: 5,
                  thickness: 2,
                  color: AppColors.greyTextColor,
                ),
                // === Секция: Ранее загруженные документы (только просмотр) ===
                if (_existingDocuments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(24),
                        Text(
                          'Ранее загруженные документы',
                          style: AppTextStyles.fs14w600
                              .copyWith(color: AppColors.greyTextColor2),
                        ),
                        const Gap(8),
                        SizedBox(
                          height: 150 * _existingDocuments.length.toDouble(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            // physics: const NeverScrollableScrollPhysics(),
                            itemCount: _existingDocuments.length,
                            itemBuilder: (context, index) {
                              final url = _existingDocuments[index];
                              final isImage = url.endsWith('.png') ||
                                  url.endsWith('.jpg') ||
                                  url.endsWith('.jpeg');
                              final name = Uri.parse(url).pathSegments.last;

                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: AppColors.borderColor,
                                ),
                                child: ListTile(
                                  trailing: IconButton(
                                    color: AppColors.red2,
                                    onPressed: () async {
                                      final url = _existingDocuments[index];
                                      await context
                                          .read<LoadDocumentsCubit>()
                                          .deleteDocument(url);
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                    ),
                                  ),
                                  leading: isImage
                                      ? const Icon(Icons.image,
                                          color: AppColors.mainColor)
                                      : const Icon(
                                          Icons.insert_drive_file,
                                          color: AppColors.greyTextColor2,
                                        ),
                                  title: Text(
                                    name,
                                    style: AppTextStyles.fs16w400,
                                  ),
                                  onTap: () async {
                                    if (!await launchUrl(Uri.parse(url))) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Не удалось открыть файл')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(
                  height: 5,
                  thickness: 2,
                  color: AppColors.greyTextColor,
                ),
                // Изображения — GridView
                if (_imageFiles.isNotEmpty)
                  Expanded(
                    flex: (_imageFiles.length > 3) ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
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
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(right: 8.0, bottom: 8),
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
                                leading: const Icon(
                                  Icons.insert_drive_file,
                                  color: AppColors.greyTextColor2,
                                ),
                                title: Text(_getDisplayName(
                                    _documentFiles[index].path)),
                                trailing: SizedBox(
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
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                // Кнопка "+"

                // // Кнопка отправки

                // Padding(
                //   padding: const EdgeInsets.only(top: 24, bottom: 24),
                //   child: CustomButton(
                //     onPressed:
                //         (_imageFiles.isEmpty && _documentFiles.isEmpty) ||
                //                 _selectedCompany == null ||
                //                 isCompaniesLoading ||
                //                 isVerificationLoading
                //             ? null
                //             : () {
                //                 final allFiles = [
                //                   ..._imageFiles,
                //                   ..._documentFiles
                //                 ];
                //                 context
                //                     .read<LoadDocumentsCubit>()
                //                     .uploadDocuments(allFiles);
                //               },
                //     style: ButtonStyle(
                //         minimumSize: WidgetStateProperty.all(
                //             const Size(double.infinity, 56))),
                //     child: Text(
                //       context.localized.send,
                //       style: AppTextStyles.fs16w500
                //           .copyWith(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SendButtonWidget extends StatelessWidget {
  const SendButtonWidget({
    super.key,
    required this.imageFiles,
    required this.documentFiles,
    required this.selectedCompany,
    required this.isCompaniesLoading,
    required this.isVerificationLoading,
  });
  final List<File> imageFiles;
  final List<File> documentFiles;
  final ProductDTO? selectedCompany;
  final bool isCompaniesLoading;
  final bool isVerificationLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
      child: CustomButton(
        onPressed: (imageFiles.isEmpty && documentFiles.isEmpty) ||
                selectedCompany == null ||
                isCompaniesLoading ||
                isVerificationLoading
            ? null
            : () {
                final allFiles = [...imageFiles, ...documentFiles];
                context.read<LoadDocumentsCubit>().uploadDocuments(allFiles);
              },
        style: ButtonStyle(
            minimumSize:
                WidgetStateProperty.all(const Size(double.infinity, 56))),
        child: Text(
          context.localized.send,
          style: AppTextStyles.fs16w500.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
