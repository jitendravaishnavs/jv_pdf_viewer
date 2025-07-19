import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jv_easy_pdf_viewer_method_channel.dart';

abstract class JvEasyPdfViewerPlatform extends PlatformInterface {
  /// Constructs a JvEasyPdfViewerPlatform.
  JvEasyPdfViewerPlatform() : super(token: _token);

  static final Object _token = Object();

  static JvEasyPdfViewerPlatform _instance = MethodChannelJvEasyPdfViewer();

  /// The default instance of [JvEasyPdfViewerPlatform] to use.
  ///
  /// Defaults to [MethodChannelJvEasyPdfViewer].
  static JvEasyPdfViewerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JvEasyPdfViewerPlatform] when
  /// they register themselves.
  static set instance(JvEasyPdfViewerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
