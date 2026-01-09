import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';

// Mock Implementation of FirebasePlatform
class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return FirebaseAppPlatform(
      name, 
      const FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return FirebaseAppPlatform(
      name ?? defaultFirebaseAppName,
      options ?? const FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [
        FirebaseAppPlatform(
          defaultFirebaseAppName,
          const FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ),
        ),
      ];
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Override the internal platform instance with our pure Dart mock.
  // This bypasses MethodChannels/Pigeon entirely.
  FirebasePlatform.instance = MockFirebasePlatform();

  // We still need to mock Auth channel because FirebaseAuth calls it directly sometimes
  const MethodChannel authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    authChannel,
    (MethodCall methodCall) async {
      return null;
    },
  );
}