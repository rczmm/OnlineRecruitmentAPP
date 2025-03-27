import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFFDFF2BF);
  static const Color white = Colors.white;
  static const Color black87 = Colors.black87;
  static const Color grey = Colors.grey;

  // 50% 透明度的灰色 (alpha = 128 = 0x80)
  static const Color grey50 = Color(0x809E9E9E);

  // 80% 透明度的灰色 (alpha = 204 = 0xCC)
  static const Color grey80 = Color(0xCC9E9E9E);
}

class AppTheme {
  AppTheme._(); // This class is not meant to be instantiated.

  static ThemeData get lightTheme {
    // 可以从 ThemeData.light() 开始，然后使用 copyWith 进行修改，更健壮
    final baseTheme = ThemeData.light();

    return baseTheme.copyWith(
      // 1. 使用 ColorScheme (现代 Flutter 推荐)
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        // 可以覆盖特定颜色
        surface: AppColors.white,
        onSurface: AppColors.black87,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
      ),

      // 2. 保留 primarySwatch 兼容旧组件，或直接使用 colorScheme.primary
      primaryColor: AppColors.primary,

      // 3. Scaffold 背景色
      scaffoldBackgroundColor: AppColors.white,

      // 4. 文本主题 (建议定义更多样式)
      textTheme: baseTheme.textTheme
          .copyWith(
            bodyMedium:
                const TextStyle(fontSize: 16.0, color: AppColors.black87),
            // 可以添加 headlineLarge, titleMedium 等其他样式
          )
          .apply(
            // 统一应用默认颜色
            bodyColor: AppColors.black87,
            displayColor: AppColors.black87,
          ),

      // 5. AppBar 主题
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        // 控制标题和图标默认颜色
        elevation: 2,
        titleTextStyle: TextStyle(
            color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: AppColors.white), // AppBar 内图标颜色
      ),

      // 6. ElevatedButton 主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // 背景色
          foregroundColor: AppColors.white, // 前景色 (文本、图标)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 16), // 推荐添加 padding
        ),
      ),

      // 7. Card 主题
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: AppColors.grey.withAlpha(50),
        margin: const EdgeInsets.all(8.0), // 推荐添加默认 margin
      ),

      // 8. InputDecoration 主题 (用于 TextField 等)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // 可以设置背景填充
        fillColor: AppColors.white,
        // 填充颜色
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        // 调整内边距
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2.0), // 焦点时边框加粗
        ),
        enabledBorder: OutlineInputBorder(
          // 非焦点时的边框
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.grey50), // 稍微柔和的边框
        ),
        border: OutlineInputBorder(
          // 默认边框 (例如错误状态等)
          borderRadius: BorderRadius.circular(8.0),
        ),
        labelStyle: const TextStyle(color: AppColors.grey),
        // Label 文本样式
        hintStyle: TextStyle(color: AppColors.grey80), // Hint 文本样式
      ),

      // 9. Icon 主题 (不在 AppBar 或 Button 内的默认图标颜色)
      iconTheme: const IconThemeData(color: AppColors.primary),

      // 10. Chip 主题
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLight,
        labelStyle: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        side: BorderSide.none, // 移除默认边框
      ),
    );
  }
}
