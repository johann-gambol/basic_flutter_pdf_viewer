import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'basicflutterpdfviewer.dart';

import 'dart:io' show Platform;

class PDFViewer extends StatefulWidget {
  final PreferredSizeWidget appBar;
  final String path;
  final bool primary;
  final bool swipeHorizontal;
  final double topBarHeight;
  final Color primaryColor;
  final Color accentColor;
  final String topBarText;

  const PDFViewer({
    Key key,
    this.appBar,
    @required this.path,
    this.primary = true,
    this.topBarHeight,
    this.swipeHorizontal = false,
    this.primaryColor,
    this.accentColor,
    this.topBarText = "Pdf Viewer",
  }) : super(key: key);

  @override
  _PDFViewScaffoldState createState() => new _PDFViewScaffoldState();
}

class _PDFViewScaffoldState extends State<PDFViewer> {
  final pdfViwerRef = PDFViewerPlugin();
  static Border borderDivider =
      Border(bottom: BorderSide(color: Colors.black12));
  static EdgeInsets topBarPadding = const EdgeInsets.all(8.0);

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

  void launchOrResizePDFRect(){
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

  Widget androidPageCounter() {
    if (Platform.isAndroid) {
      return ChangeNotifierProvider(
        create: (context) => PDFViewerPlugin(),
        child: Consumer<PDFViewerPlugin>(
          builder: (context, model, child) {
            return Text(
              model.currentPage.toString() + ' / ' + model.pageCount.toString(),
            );
          },
        ),
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    launchOrResizePDFRect();
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: widget.topBarHeight,
          decoration: BoxDecoration(
              color: widget.primaryColor ?? Theme.of(context).primaryColor,
              border: borderDivider),
          child: Padding(
            padding: topBarPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: FlatButton(
                    child: Icon(
                      Icons.arrow_back,
                      color:
                          widget.accentColor ?? Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      await pdfViwerRef.close();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(flex: 6, child: Text(widget.topBarText)),
                Expanded(flex: 2, child: androidPageCounter()),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
