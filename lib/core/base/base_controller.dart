import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

enum ViewState { idle, loading, error, empty, success }

abstract class BaseController extends GetxController {
  final Rx<ViewState> _viewState = ViewState.idle.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isRefreshing = false.obs;
  
  ViewState get viewState => _viewState.value;
  String get errorMessage => _errorMessage.value;
  bool get isRefreshing => _isRefreshing.value;
  
  bool get isLoading => _viewState.value == ViewState.loading;
  bool get isError => _viewState.value == ViewState.error;
  bool get isEmpty => _viewState.value == ViewState.empty;
  bool get isSuccess => _viewState.value == ViewState.success;
  bool get isIdle => _viewState.value == ViewState.idle;
  
  @override
  void onInit() {
    super.onInit();
    LoggerService.d('${runtimeType} initialized');
  }
  
  @override
  void onReady() {
    super.onReady();
    LoggerService.d('${runtimeType} ready');
    loadData();
  }
  
  @override
  void onClose() {
    LoggerService.d('${runtimeType} closed');
    super.onClose();
  }
  
  void loadData() {
    // Override in child controllers
  }
  
  void setLoading() {
    _viewState.value = ViewState.loading;
    _errorMessage.value = '';
  }
  
  void setIdle() {
    _viewState.value = ViewState.idle;
    _errorMessage.value = '';
  }
  
  void setSuccess() {
    _viewState.value = ViewState.success;
    _errorMessage.value = '';
  }
  
  void setEmpty() {
    _viewState.value = ViewState.empty;
    _errorMessage.value = '';
  }
  
  void setError(String message, {dynamic error, StackTrace? stackTrace}) {
    _viewState.value = ViewState.error;
    _errorMessage.value = message;
    LoggerService.e(
      'Error in ${runtimeType}: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  void setRefreshing(bool value) {
    _isRefreshing.value = value;
  }
  
  Future<void> refreshData() async {
    setRefreshing(true);
    loadData();
    setRefreshing(false);
  }
  
  Future<T?> runBusyFuture<T>(
    Future<T> Function() busyFunction, {
    String? busyMessage,
    bool throwException = false,
  }) async {
    setLoading();
    try {
      final result = await busyFunction();
      if (result == null || (result is List && result.isEmpty)) {
        setEmpty();
      } else {
        setSuccess();
      }
      return result;
    } catch (e, s) {
      setError(e.toString(), error: e, stackTrace: s);
      if (throwException) rethrow;
      return null;
    }
  }
  
  Future<T?> runErrorFuture<T>(
    Future<T> Function() function, {
    String? errorMessage,
    bool showLoading = false,
  }) async {
    if (showLoading) setLoading();
    try {
      final result = await function();
      if (showLoading) setIdle();
      return result;
    } catch (e, s) {
      setError(errorMessage ?? e.toString(), error: e, stackTrace: s);
      return null;
    }
  }
}