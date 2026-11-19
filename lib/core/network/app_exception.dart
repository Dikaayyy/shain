import 'package:shain/core/constants/app_strings.dart';

/// Kategori error aplikasi untuk membedakan masalah jaringan, server, dan lainnya.
enum AppExceptionType { network, server, unknown }

/// Representasi error ramah pengguna untuk lapisan data dan UI.
class AppException implements Exception {
  const AppException({
    required this.type,
    required this.title,
    required this.message,
    this.statusCode,
  });

  final AppExceptionType type;
  final String title;
  final String message;
  final int? statusCode;

  factory AppException.network() {
    return const AppException(
      type: AppExceptionType.network,
      title: AppStrings.networkErrorTitle,
      message: AppStrings.networkErrorMessage,
    );
  }

  factory AppException.server([int? statusCode]) {
    return AppException(
      type: AppExceptionType.server,
      title: AppStrings.serverErrorTitle,
      message: AppStrings.serverErrorMessage,
      statusCode: statusCode,
    );
  }

  factory AppException.unknown() {
    return const AppException(
      type: AppExceptionType.unknown,
      title: AppStrings.unknownErrorTitle,
      message: AppStrings.unknownErrorMessage,
    );
  }

  @override
  String toString() => 'AppException($type, statusCode: $statusCode): $title';
}
