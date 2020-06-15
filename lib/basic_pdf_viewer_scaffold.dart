import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'basicflutterpdfviewer.dart';

class PDFViewer extends StatefulWidget {
  final PreferredSizeWidget appBar;
  final String path;
  final bool primary;
  final bool swipeHorizontal;
  final double topBarHeight;
  final Color topBarColor;
  final String topBarText;

  const PDFViewer({
    Key key,
    this.appBar,
    @required this.path,
    this.primary = true,
    this.topBarHeight,
    this.swipeHorizontal = false,
    this.topBarColor = Colors.white,
    this.topBarText = "Pdf Viewer",
  }) : super(key: key);

  @override
  _PDFViewScaffoldState createState() => new _PDFViewScaffoldState();
}

class _PDFViewScaffoldState extends State<PDFViewer> {
  final pdfViwerRef = PDFViewerPlugin();

  Rect _rect;
  Timer _resizeTimer;

  @override
  void initState() {
    super.initState();
    pdfViwerRef.close();
  }

  @override
  void dispose() {
    super.dispose();
    pdfViwerRef.close();
    pdfViwerRef.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rect == null) {
      _rect = _buildRect(context);
      pdfViwerRef.launch(
        path: widget.path,
        rect: _rect,
        swipeHorizontal: widget.swipeHorizontal,
      );
    } else {
      final rect = _buildRect(context);
      if (_rect != rect) {
        _rect = rect;
        _resizeTimer?.cancel();
        _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
          pdfViwerRef.resize(_rect);
        });
      }
    }
    return Container(
      height: widget.topBarHeight,
      color: widget.topBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            child: Icon(
              Icons.arrow_back,
              color: widget.topBarColor == Colors.white
                  ? Colors.black87
                  : widget.topBarColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(widget.topBarText),
        ],
      ),
    );
  }

  Rect _buildRect(BuildContext context) {
    final fullscreen = widget.topBarHeight == null;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    final top = fullscreen ? 0.0 : widget.topBarHeight + topPadding;
    var height = mediaQuery.size.height - top;
    if (height < 0.0) {
      height = 0.0;
    }

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }
}
