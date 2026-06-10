import 'package:flutter/material.dart';

/// Extension methods for [BuildContext]
extension BuildContextExtensions on BuildContext {
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme
  ColorScheme get colors => theme.colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if the device is in dark mode
  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;

  /// Get device size
  Size get deviceSize => MediaQuery.of(this).size;

  /// Get device width
  double get deviceWidth => deviceSize.width;

  /// Get device height
  double get deviceHeight => deviceSize.height;

  /// Check if device is in portrait mode
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Get the padding for the current device (safe area)
  EdgeInsets get devicePadding => MediaQuery.of(this).padding;

  /// Get the view insets for the current device (keyboard height, etc)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Show a snackbar with a message
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Show an error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
      ),
    );
  }

  /// Show a success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.primary,
      ),
    );
  }

  /// Pop current route and return a value
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Push a named route
  Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  Future<T?> pushReplacementNamed<T>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }
}
