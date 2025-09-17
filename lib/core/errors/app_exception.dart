import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => message;
  
  factory AppException.fromFirebaseAuth(FirebaseAuthException e) {
    String message = 'Authentication error occurred';
    
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Wrong password provided';
        break;
      case 'email-already-in-use':
        message = 'Email is already registered';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials provided';
        break;
      default:
        message = e.message ?? 'Authentication error occurred';
    }
    
    return AppException(
      message: message,
      code: e.code,
      originalError: e,
    );
  }
  
  factory AppException.fromFirestore(FirebaseException e) {
    String message = 'Database error occurred';
    
    switch (e.code) {
      case 'permission-denied':
        message = 'You don\'t have permission to perform this action';
        break;
      case 'unavailable':
        message = 'Service temporarily unavailable. Please try again';
        break;
      case 'cancelled':
        message = 'Operation was cancelled';
        break;
      case 'deadline-exceeded':
        message = 'Operation timed out. Please try again';
        break;
      case 'not-found':
        message = 'Requested data not found';
        break;
      case 'already-exists':
        message = 'Data already exists';
        break;
      case 'resource-exhausted':
        message = 'Quota exceeded. Please try again later';
        break;
      case 'failed-precondition':
        message = 'Operation failed. Please try again';
        break;
      case 'aborted':
        message = 'Operation aborted due to conflict';
        break;
      case 'out-of-range':
        message = 'Operation out of valid range';
        break;
      case 'unimplemented':
        message = 'Operation not implemented';
        break;
      case 'internal':
        message = 'Internal error occurred';
        break;
      case 'data-loss':
        message = 'Data loss or corruption detected';
        break;
      case 'unauthenticated':
        message = 'Please sign in to continue';
        break;
      default:
        message = e.message ?? 'Database error occurred';
    }
    
    return AppException(
      message: message,
      code: e.code,
      originalError: e,
    );
  }
  
  factory AppException.fromError(dynamic error) {
    if (error is FirebaseAuthException) {
      return AppException.fromFirebaseAuth(error);
    } else if (error is FirebaseException) {
      return AppException.fromFirestore(error);
    } else if (error is AppException) {
      return error;
    } else {
      return AppException(
        message: error.toString(),
        originalError: error,
      );
    }
  }
}

class NetworkException extends AppException {
  NetworkException({String? message})
      : super(
          message: message ?? 'Network connection error',
          code: 'network-error',
        );
}

class ValidationException extends AppException {
  ValidationException({required String message})
      : super(
          message: message,
          code: 'validation-error',
        );
}

class NotFoundException extends AppException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Requested data not found',
          code: 'not-found',
        );
}

class UnauthorizedException extends AppException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized access',
          code: 'unauthorized',
        );
}

class ServerException extends AppException {
  ServerException({String? message})
      : super(
          message: message ?? 'Server error occurred',
          code: 'server-error',
        );
}