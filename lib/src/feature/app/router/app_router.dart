import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/feature/auth/presentation/pages/onboarding_page.dart';
import 'package:coment_app/src/feature/catalog/model/create_product_model.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/detail_all_image_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/detail_avatar_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/detail_image_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/add_feedback_searching_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/filter_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/leave_feedback_detail_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/leave_feedback_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/product_list_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/read_all_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/select_categories_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/subcatalog_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/product_detail_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/feedback_detail_page.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter/material.dart';
import 'package:coment_app/src/feature/app/presentation/pages/launcher.dart';
import 'package:coment_app/src/feature/app/presentation/pages/temp_page.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/auth/presentation/auth.dart';
import 'package:coment_app/src/feature/auth/presentation/pages/auth_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/catalog.dart';
import 'package:coment_app/src/feature/main/presentation/main.dart';
import 'package:coment_app/src/feature/profile/presentation/profile.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: TempRoute.page),
        // AutoRoute(
        //   initial: true,
        //   page: OnboardingRoute.page,
        // ),

        /// Root
        AutoRoute(
          page: LauncherRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: BaseMainFeedTab.page,
              children: [
                AutoRoute(
                  page: MainRoute.page,
                  initial: true,
                ),
              ],
            ),
            AutoRoute(
              page: BaseCatalogTab.page,
              children: [
                AutoRoute(
                  page: CatalogRoute.page,
                  initial: true,
                ),
              ],
            ),
            AutoRoute(
              page: BaseProfileTab.page,
              children: [
                AutoRoute(
                  page: ProfileRoute.page,
                  initial: true,
                  // children: const [],
                ),
              ],
            ),
          ],
        ),

        /// Auth
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: AuthRoute.page),
        AutoRoute(page: PasswordRecoveryRoute.page),
        AutoRoute(page: EnterSmsCodeRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: NewPasswordRoute.page),

        //

        AutoRoute(page: OnboardingRoute.page),

        /// Main
        ///

        /// Profile
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: EditProfileRoute.page),
        AutoRoute(page: ReviewHistoryRoute.page),
        AutoRoute(page: RaitingRoute.page),

        //Catalog
        AutoRoute(page: SubcatalogRoute.page),
        AutoRoute(page: ProductListRoute.page),
        AutoRoute(page: ProductDetailRoute.page),
        AutoRoute(page: FeedbackDetailRoute.page),
        AutoRoute(page: FilterRoute.page),
        AutoRoute(page: ReadAllRoute.page),
        AutoRoute(page: LeaveFeedbackRoute.page),
        AutoRoute(page: DetailImageRoute.page),
        AutoRoute(page: DetailAllImageRoute.page),
        AutoRoute(page: DetailAvatarRoute.page),
        AutoRoute(page: AddFeedbackSearchingRoute.page),
        AutoRoute(page: SelectCategoriesRoute.page),
        AutoRoute(page: LeaveFeedbackDetailRoute.page),
      ];
}

@RoutePage(name: 'BaseMainFeedTab')
class BaseMainFeedPage extends AutoRouter {
  const BaseMainFeedPage({super.key});
}

@RoutePage(name: 'BaseCatalogTab')
class BaseCatalogPage extends AutoRouter {
  const BaseCatalogPage({super.key});
}

@RoutePage(name: 'BaseProfileTab')
class BaseProfilePage extends AutoRouter {
  const BaseProfilePage({super.key});
}
