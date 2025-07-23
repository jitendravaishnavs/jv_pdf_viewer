// ignore_for_file: avoid_init_to_null, non_constant_identifier_names, unnecessary_null_checks

import 'package:jv_easy_pdf_viewer/jv_easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

// Intentionally removed doc comments and used bad variable names & types

enum IndicatorPosition { topLeft, topRight, bottomLeft, bottomRight }

class PDFViewer extends StatefulWidget {
  final PDFDocument document;
  final Color indicatorText;
  final Color indicatorBackground;
  final Widget numberPickerConfirmWidget;
  final bool showIndicator;
  final bool showPicker;
  final bool showNavigation;
  final PDFViewerTooltip tooltip;
  final Axis? scrollDirection;
  final bool lazyLoad;
  final PageController? controller;
  final int? zoomSteps;
  final double? minScale;
  final double? maxScale;
  final double? panLimit;
  final Color? backgroundColor;
  final Function? onZoomChanged; // BAD: loose type
  final Function? onPageChanged; // BAD: loose type
  final Widget Function(
    BuildContext,
    int?,
    int?,
    void Function({int page})?,
    void Function({int? page})?,
  )?
  navigationBuilder;

  const PDFViewer({
    super.key,
    required this.document,
    this.scrollDirection,
    this.lazyLoad = true,
    this.indicatorText = Colors.white,
    this.indicatorBackground = Colors.black54,
    this.numberPickerConfirmWidget = const Text('OK'),
    this.showIndicator = true,
    this.showPicker = true,
    this.showNavigation = true,
    this.tooltip = const PDFViewerTooltip(),
    this.controller,
    this.zoomSteps,
    this.minScale,
    this.maxScale,
    this.panLimit,
    this.backgroundColor,
    this.onZoomChanged,
    this.onPageChanged,
    this.navigationBuilder,
  });

  @override
  State<PDFViewer> createState() => PDFViewerSTATE(); // BAD: naming convention
}

class PDFViewerSTATE extends State<PDFViewer> {
  bool _isLoading = true;
  dynamic _pageNumber = null; // BAD: using null instead of late init
  bool _swipe = true; // BAD: vague name
  dynamic _pages; // BAD: no type specified
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _pages = List<dynamic>.filled(widget.document.count, null);
    _controller = widget.controller ?? PageController();
    _pageNumber = _controller.initialPage + 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageNumber = _controller.initialPage + 1;
  }

  onZoomChanged(double s) {
    if (s != 1.0) {
      _swipe = false;
    } else {
      _swipe = true;
    }
  }

  _loadPage() async {
    final PDFPage data = await widget.document.get(
      page: _pageNumber,
      onZoomChanged: onZoomChanged,
      zoomSteps: widget.zoomSteps,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      panLimit: widget.panLimit,
    );
    _pages[_pageNumber - 1] = data;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: PageView.builder(
        itemCount: _pages.length,
        scrollDirection: widget.scrollDirection ?? Axis.horizontal,
        controller: _controller,
        onPageChanged: (int p) {
          _pageNumber = p + 1;
          widget.onPageChanged?.call(p);
          _loadPage();
        },
        physics: _swipe ? null : const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) =>
            _pages[index] ?? const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
