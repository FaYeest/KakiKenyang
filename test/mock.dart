import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocking the MethodChannel for Firebase Auth
  const MethodChannel authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    authChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'Auth#registerIdTokenListener' ||
          methodCall.method == 'Auth#authStateChanges' ||
          methodCall.method == 'Auth#idTokenChanges' ||
          methodCall.method == 'Auth#userChanges') {
        return null;
      }
      return null;
    },
  );

  // Mocking the Pigeon Channel for Firebase Core (Newer versions)
  const MethodChannel corePigeonChannel = MethodChannel(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
  );
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    corePigeonChannel,
    (MethodCall methodCall) async {
      return {
        'name': '[DEFAULT]',
        'options': {
          'apiKey': '123',
          'appId': '123',
          'messagingSenderId': '123',
          'projectId': '123',
        },
        'pluginConstants': {},
      };
    },
  );

  // Fallback for older MethodChannel style
  const MethodChannel coreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    coreChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
          }
        ];
      }
      return null;
    },
  );
}