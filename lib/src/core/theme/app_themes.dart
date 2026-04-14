part of 'resources.dart';

mixin AppTheme {
  static ThemeData get light => ThemeData(
        fontFamily: AssetsConstants.golosTextBlack,
        useMaterial3: true,
        // typography: Typography.material2014(),
        textTheme: const TextTheme(
          displayLarge: TextStyle(letterSpacing: -1),
          displayMedium: TextStyle(letterSpacing: -1),
          displaySmall: TextStyle(letterSpacing: -1),
          bodyLarge: TextStyle(letterSpacing: -1),
          bodyMedium: TextStyle(letterSpacing: -1),
          bodySmall: TextStyle(letterSpacing: -1),
          titleLarge: TextStyle(color: AppColors.text),
        ),
        cardTheme: const CardThemeData(
          // ← CardThemeData — это данные для темы!
          color: Color(0xFFF8F8F8),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.mainColor,
            secondary: AppColors.mainColor,
            primaryContainer: AppColors.white,
            onSecondary: AppColors.white,
            primary: AppColors.backgroundInputGrey,
            onPrimaryContainer: AppColors.greyTextColor,
            onSecondaryContainer: Colors.grey[400]?.withValues(alpha: 0.6)
            // surface: AppLightColors.base100,
            ),
        // // fontFamily: Platform.isIOS ? FontFamily.sFPro : null,
        scaffoldBackgroundColor: AppColors.white,
        brightness: Brightness.light,
        // primaryColor: AppLightColors.mainColor,
        // progressIndicatorTheme: const ProgressIndicatorThemeData(
        //   color: AppLightColors.mainColor,
        // ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.white,
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: AppColors.greyTextColor),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          modalBarrierColor: Color.fromRGBO(0, 0, 0, 0.5),
          dragHandleColor: Color(0xffCCCCCC),
          dragHandleSize: Size(48, 4),
          // showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        // textSelectionTheme: const TextSelectionThemeData(
        //   cursorColor: AppLightColors.mainColor,
        // ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundInputGrey,
          hintStyle: TextStyle(
            fontSize: 16,
            color: AppColors.greyText,
            letterSpacing: -1,
          ),
          errorStyle: TextStyle(
            fontSize: 14,
            color: AppColors.red,
            letterSpacing: -1,
          ),
          // counterStyle: TextStyle(
          //   fontSize: 11,
          //   color: AppLightColors.base500,
          // ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.line2, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.red),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.red),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.line2, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.line2, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.text,
              width: 0.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.mainColor,
            disabledBackgroundColor: AppColors.line2,
            disabledForegroundColor: AppColors.text,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.tabActive,
          labelStyle: TextStyle(
            fontSize: 11,
            // height: 18 / 12,
          ),
          labelPadding: EdgeInsets.zero,
          unselectedLabelColor: AppColors.base400,
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            // height: 18 / 12,
          ),
        ),

        // dialogBackgroundColor: AppLightColors.base50,
        // checkboxTheme: const CheckboxThemeData(
        //   side: BorderSide(
        //     color: AppLightColors.base200,
        //     width: 2,
        //   ),
        // ),
        // floatingActionButtonTheme: const FloatingActionButtonThemeData(shape: CircleBorder()),
      );

  static ThemeData get dark => ThemeData(
        fontFamily: AssetsConstants.golosTextBlack,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1B1C1E),
        textTheme: const TextTheme(
          displayLarge: TextStyle(letterSpacing: -1),
          displayMedium: TextStyle(letterSpacing: -1),
          displaySmall: TextStyle(letterSpacing: -1),
          bodyLarge: TextStyle(letterSpacing: -1, color: Colors.white),
          bodyMedium: TextStyle(letterSpacing: -1, color: Colors.white),
          bodySmall: TextStyle(
            letterSpacing: -1,
            color: Color(0xFF9E9E9E),
          ),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
       
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.mainColor,
            secondary: AppColors.mainColor,
            brightness: Brightness.dark,
            primaryContainer: const Color(0xFF27282C),
            onSecondary: const Color(0xFF292A2E),
            primary: AppColors.greyTextColor,
            onPrimaryContainer: const Color(0xFF292A2E),
            onSecondaryContainer:
                const Color(0xFF292A2E).withValues(alpha: 0.6)),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF1E1E1E), // Темный фон AppBar
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          modalBarrierColor: Color.fromRGBO(0, 0, 0, 0.7),
          dragHandleColor: Color(0xFF424242),
          dragHandleSize: Size(48, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2C2C2C), // Темный фон полей ввода
          hintStyle: TextStyle(
            fontSize: 16,
            color: Color(0xFF9E9E9E), // Светло-серый текст подсказки
            letterSpacing: -1,
          ),
          errorStyle: TextStyle(
            fontSize: 14,
            color: Color(0xFFEF5350), // Красный для ошибок
            letterSpacing: -1,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF424242), width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEF5350)),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEF5350)),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF424242), width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF424242), width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.mainColor,
              width: 0.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.mainColor,
            disabledBackgroundColor: const Color(0xFF424242),
            disabledForegroundColor: const Color(0xFF9E9E9E),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.mainColor,
          labelStyle: TextStyle(
            fontSize: 11,
          ),
          labelPadding: EdgeInsets.zero,
          unselectedLabelColor: Color(0xFF9E9E9E),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
          ),
          indicatorColor: AppColors.mainColor,
        ),
        cardTheme: const CardThemeData(
          // ← CardThemeData — это данные для темы!
          color: Color(0xFF111217),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        dividerColor: const Color(0xFF424242),
      );
}
