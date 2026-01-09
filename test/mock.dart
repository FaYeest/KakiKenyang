import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_auth');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'Auth#registerIdTokenListener') {
        return null;
      }
      if (methodCall.method == 'Auth#authStateChanges') {
        return null;
      }
       if (methodCall.method == 'Auth#idTokenChanges') {
        return null;
      }
      if (methodCall.method == 'Auth#userChanges') {
        return null;
      }
      if (customHandlers != null) {
        customHandlers(methodCall);
      }
      return null;
    },
  );

  // Mock Firebase Core initialization
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
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );
}
