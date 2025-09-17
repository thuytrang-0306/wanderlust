import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/presentation/pages/community/saved_collections_page.dart';

class SavedCollectionsController extends BaseController {
  final RxList<CollectionModel> collections = <CollectionModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCollections();
  }
  
  void loadCollections() {
    // Mock data - in real app, load from database
    collections.value = [
      CollectionModel(
        id: 'all',
        name: 'Tất cả bài viết',
        images: [
          'https://images.unsplash.com/photo-1564674244660-2b7a0e4afb1e?w=400',
          'https://images.unsplash.com/photo-1509023464722-18d996393ca8?w=400',
          'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
          'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
        ],
        postCount: 15,
        isDefault: true,
      ),
      CollectionModel(
        id: 'spring',
        name: 'Mùa xuân',
        images: [
          'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=400',
          'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?w=400',
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
        ],
        postCount: 8,
      ),
      CollectionModel(
        id: 'date_collection',
        name: '21/6/2026',
        images: [
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400',
          'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400',
        ],
        postCount: 5,
      ),
    ];
  }
  
  void openCollection(CollectionModel collection) {
    Get.toNamed('/collection-detail', arguments: {
      'collectionId': collection.id,
      'collectionName': collection.name,
    });
  }
  
  void createNewCollection() {
    Get.defaultDialog(
      title: 'Tạo bộ sưu tập mới',
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: EdgeInsets.all(16.w),
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tên bộ sưu tập',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Hủy',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Create collection
            Get.back();
            Get.snackbar(
              'Thành công',
              'Đã tạo bộ sưu tập mới',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: Text('Tạo'),
        ),
      ],
    );
  }
}