import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class SavedCollectionsController extends BaseController {
  // Lazy load SavedBlogsService
  SavedBlogsService get _savedBlogsService {
    if (!Get.isRegistered<SavedBlogsService>()) {
      Get.put(SavedBlogsService());
    }
    return Get.find<SavedBlogsService>();
  }

  // Observable collections from service
  RxList<BlogCollection> get collections => _savedBlogsService.collections;

  @override
  void onInit() {
    super.onInit();
    _loadCollections();
  }

  void _loadCollections() async {
    setLoading();
    // Ensure service is initialized
    _savedBlogsService;
    setSuccess();
  }

  void openCollection(BlogCollection collection) {
    Get.toNamed(
      '/collection-detail',
      arguments: {'collectionId': collection.id, 'collectionName': collection.name},
    );
  }

  void createNewCollection() {
    final TextEditingController nameController = TextEditingController();
    
    Get.defaultDialog(
      title: 'Tạo bộ sưu tập mới',
      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
      contentPadding: EdgeInsets.all(16.w),
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Tên bộ sưu tập',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              await _savedBlogsService.createCollection(name);
              Get.back();
              AppSnackbar.showSuccess(
                message: 'Đã tạo bộ sưu tập "$name"',
              );
            }
          },
          child: Text('Tạo'),
        ),
      ],
    );
  }
  
  // Get collection images for display
  List<String> getCollectionImages(BlogCollection collection) {
    final savedBlogs = _savedBlogsService.getSavedBlogsForCollection(collection.id);
    return savedBlogs
        .where((blog) => blog.coverImage.isNotEmpty)
        .take(4)
        .map((blog) => blog.coverImage)
        .toList();
  }
}
