import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/catalog_list_item.dart';
import 'package:coment_app/src/feature/main/bloc/subcatalog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SubcatalogPage extends StatefulWidget implements AutoRouteWrapper {
  const SubcatalogPage({super.key, required this.title, required this.catalogId});

  final String title;
  final int catalogId;

  @override
  State<SubcatalogPage> createState() => _SubcatalogPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => SubcatalogCubit(
          repository: context.repository.mainRepository,
        ),
      ),
    ], child: this);
  }
}

class _SubcatalogPageState extends State<SubcatalogPage> {
  @override
  void initState() {
    BlocProvider.of<SubcatalogCubit>(context).getSubcatalogList(catalogId: widget.catalogId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        actions: [
          Container(
            width: 40,
          )
        ],
      ),
      body: BlocConsumer<SubcatalogCubit, SubcatalogState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            loading: () {},
            loaded: (data) {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
              orElse: () => const Center(
                    child: Text('Something is Error'),
                  ),
              loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
              loaded: (response) => response.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 12),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: response.length,
                            itemBuilder: (context, index) {
                              return CatalogListItem(
                                isCatalog: false,
                                subCatalog: response[index],
                                onTap: () {
                                  context.router.push(ProductListRoute(
                                      subcatalogId: response[index].id,
                                      // subCatalogTitle: response[index].name,
                                      subCatalogTitle: context.currentLocale.toString() == 'kk'
                                          ? '${response[index].nameKk}'
                                          : context.currentLocale.toString() == 'en'
                                              ? '${response[index].nameEn}'
                                              : context.currentLocale.toString() == 'uz'
                                                  ? '${response[index].nameUz}'
                                                  : response[index].name));
                                },
                              );
                            },
                          )
                        ],
                      ),
                    )
                  : const Center(
                      child: Text('Is empty'),
                    ));
        },
      ),
    );
  }
}
