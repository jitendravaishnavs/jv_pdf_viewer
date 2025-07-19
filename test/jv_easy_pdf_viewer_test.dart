import 'package:flutter_test/flutter_test.dart';
import 'package:jv_easy_pdf_viewer/jv_easy_pdf_viewer.dart';
import 'package:jv_easy_pdf_viewer/jv_easy_pdf_viewer_platform_interface.dart';
import 'package:jv_easy_pdf_viewer/jv_easy_pdf_viewer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJvEasyPdfViewerPlatform
    with MockPlatformInterfaceMixin
    implements JvEasyPdfViewerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final JvEasyPdfViewerPlatform initialPlatform =
      JvEasyPdfViewerPlatform.instance;

  test('$MethodChannelJvEasyPdfViewer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJvEasyPdfViewer>());
  });

  test('getPlatformVersion', () async {
    JvEasyPdfViewer jvEasyPdfViewerPlugin = JvEasyPdfViewer();
    MockJvEasyPdfViewerPlatform fakePlatform = MockJvEasyPdfViewerPlatform();
    JvEasyPdfViewerPlatform.instance = fakePlatform;

    expect(await jvEasyPdfViewerPlugin.getPlatformVersion(), '42');
  });
}
