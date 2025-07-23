import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jv_easy_pdf_viewer_platform_interface.dart';

/// An implementation of [JvEasyPdfViewerPlatform] that uses method channels.
class MethodChannelJvEasyPdfViewer extends JvEasyPdfViewerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('jv_easy_pdf_viewer');

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
