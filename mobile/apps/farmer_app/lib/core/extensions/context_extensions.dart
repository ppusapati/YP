import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Convenience extensions on [BuildContext] for common UI operations.
extension ContextExtensions on BuildContext {
  // ─── Theme shortcuts ──────────────────────────────────────────────

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ─── Media query shortcuts ────────────────────────────────────────

  /// The current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Bottom padding (safe area).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Top padding (safe area / status bar).
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Keyboard height.
  double get keyboardHeight => MediaQuery.viewInsetsOf(this).bottom;

  /// Whether the keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  // ─── Navigation shortcuts ─────────────────────────────────────────

  /// Navigate back.
  void goBack() => GoRouter.of(this).pop();

  /// Whether the navigator can pop.
  bool get canGoBack => GoRouter.of(this).canPop();

  // ─── Scaffold messenger ───────────────────────────────────────────

  /// Show a snackbar with the given [message].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show an error snackbar.
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show a success snackbar.
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF388E3C),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
