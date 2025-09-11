import 'package:wanderlust/core/errors/app_exception.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

/// Base class for all use cases in the application
/// Following Clean Architecture principles
abstract class BaseUseCase<Type, Params> {
  const BaseUseCase();
  
  Future<Result<Type>> call(Params params);
}

/// Use case without parameters
abstract class NoParamsUseCase<Type> {
  const NoParamsUseCase();
  
  Future<Result<Type>> call();
}

/// Result wrapper for handling success/failure
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;
  
  Result.success(this.data) 
    : error = null,
      isSuccess = true;
      
  Result.failure(this.error)
    : data = null,
      isSuccess = false;
      
  bool get isFailure => !isSuccess;
  
  void when({
    required Function(T data) success,
    required Function(AppException error) failure,
  }) {
    if (isSuccess && data != null) {
      success(data as T);
    } else if (error != null) {
      failure(error!);
    }
  }
  
  T? getOrNull() => data;
  
  T getOrElse(T defaultValue) => data ?? defaultValue;
  
  T getOrThrow() {
    if (data != null) return data as T;
    throw error ?? AppException(message: 'Unknown error');
  }
}

/// Parameters base class
abstract class Params {
  Map<String, dynamic> toJson();
}

/// Empty parameters
class NoParams extends Params {
  @override
  Map<String, dynamic> toJson() => {};
}