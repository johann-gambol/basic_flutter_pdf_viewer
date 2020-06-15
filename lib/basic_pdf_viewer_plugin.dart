import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PDFViewState { shouldStart, startLoad, finishLoad }

class PDFViewerPlugin extends ChangeNotifier {
  final _channel = const MethodChannel("basic_flutter_pdf_viewer");
  static PDFViewerPlugin _instance;

  int _pageCount = 0;
  get pageCount => _pageCount;

  int _currentPage = 1;
  get currentPage => _currentPage;

  factory PDFViewerPlugin() => _instance ??= new PDFViewerPlugin._();
  PDFViewerPlugin._() {
    _channel.setMethodCallHandler(_handleMessages);
  }

  final _onDestroy = new StreamController<Null>.broadcast();
  Stream<Null> get onDestroy => _onDestroy.stream;

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onDestroy':
        _onDestroy.add(null);
        break;
      case 'loadComplete':
        _pageCount = call.arguments;
        notifyListeners();
        break;
      case 'pageChanged':
        _currentPage = call.arguments;
        notifyListeners();
        break;
    }
  }

  Future<Null> launch({String path, bool swipeHorizontal, Rect rect}) async {
    final args = <String, dynamic>{
      'path': path,
      'swipeHorizontal': swipeHorizontal,
    };
    if (rect != null) {
      args['rect'] = {
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height
      };
    }
    await _channel.invokeMethod('launch', args);
  }

  /// Close the PDFViewer
  /// Will trigger the [onDestroy] event
  Future close() => _channel.invokeMethod('close');

  /// adds the plugin as ActivityResultListener
  /// Only needed and used on Android
  Future registerAcitivityResultListener() =>
      _channel.invokeMethod('registerAcitivityResultListener');

  /// removes the plugin as ActivityResultListener
  /// Only needed and used on Android
  Future removeAcitivityResultListener() =>
      _channel.invokeMethod('removeAcitivityResultListener');

  /// Close all Streams
  void dispose() {
    _onDestroy.close();
    _instance = null;
  }

  /// resize PDFViewer
  Future<Null> resize(Rect rect) async {
    final args = {};
    args['rect'] = {
      'left': rect.left,
      'top': rect.top,
      'width': rect.width,
      'height': rect.height
    };
    await _channel.invokeMethod('resize', args);
  }
}
