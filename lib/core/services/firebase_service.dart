import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find();
  
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late FirebaseMessaging messaging;
  
  Future<FirebaseService> init() async {
    // Firebase already initialized in main.dart
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    messaging = FirebaseMessaging.instance;
    
    await _setupMessaging();
    
    return this;
  }
  
  Future<void> _setupMessaging() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      String? token = await messaging.getToken();
      print('FCM Token: $token');
      
      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }
  
  void _handleMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');
  }
  
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Handling background message opened: ${message.messageId}');
  }
}