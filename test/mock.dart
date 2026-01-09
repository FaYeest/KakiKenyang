import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Definisi ulang interface biar gak perlu import private file
class MockFirebaseCoreHostApi {
  static void setup() {
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
      StandardMessageCodec(),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      channel.name,
      (ByteData? message) async {
        // Return list containing one App instance structure
        return const StandardMessageCodec().encodeMessage([
          [
             '[DEFAULT]', // appName
             [
               'fakeApiKey', // apiKey
               'fakeAppId', // appId
               'fakeSenderId', // messagingSenderId
               'fakeProjectId', // projectId
               null, // authDomain
               null, // databaseURL
               null, // storageBucket
               null, // measurementId
               null, // trackingId
               null, // deepLinkURLScheme
               null, // androidClientId
               null, // iosClientId
               null, // iosBundleId
               null, // appGroupId
             ],
             {}, // pluginConstants
          ]
        ]);
      },
    );
    
    // Also mock initializeApp for safety
    const BasicMessageChannel<Object?> channelApp = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeApp',
      StandardMessageCodec(),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      channelApp.name,
      (ByteData? message) async {
         final List<Object?>? args = const StandardMessageCodec().decodeMessage(message) as List<Object?>?;
         final String appName = args?[0] as String;
         final List<Object?> options = args?[1] as List<Object?>;

        return const StandardMessageCodec().encodeMessage(
          [
             appName,
             options,
             {}, // pluginConstants
          ]
        );
      },
    );
  }
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Auth (Old MethodChannel) - Masih dipake sama FirebaseAuth
  const MethodChannel authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    authChannel,
    (MethodCall methodCall) async {
      return null;
    },
  );

  // Mock Core (Pigeon)
  MockFirebaseCoreHostApi.setup();
}
