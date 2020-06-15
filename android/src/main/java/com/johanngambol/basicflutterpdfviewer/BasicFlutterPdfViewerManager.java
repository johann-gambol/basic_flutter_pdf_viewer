package com.johanngambol.basicflutterpdfviewer;

import android.app.Activity;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.listener.OnPageChangeListener;
import com.github.barteksc.pdfviewer.listener.OnLoadCompleteListener;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * BasicFlutterPdfViewerManager
 */
class BasicFlutterPdfViewerManager implements OnPageChangeListener, OnLoadCompleteListener {

    boolean closed = false;
    PDFView pdfView;
    Activity activity;


    int currentPage = 1;

    BasicFlutterPdfViewerManager(final Activity activity) {
        this.pdfView = new PDFView(activity, null);
        this.activity = activity;
    }

    void openPDF(String path, boolean swipeHorizontal, boolean pageSnap) {
        File file = new File(path);
        pdfView.fromFile(file)
                .enableSwipe(true)
                .onLoad(this)
                .swipeHorizontal(swipeHorizontal)
                .onPageChange(this)
                .enableDoubletap(true)
                .defaultPage(currentPage)
                .load();
    }

    @Override
    public void loadComplete(int nbPages) {
        BasicFlutterPdfViewerPlugin.channel.invokeMethod("loadComplete", nbPages);
    }

   @Override
   public void onPageChanged(int page, int pageCount){
       BasicFlutterPdfViewerPlugin.channel.invokeMethod("pageChanged", page + 1);
   }

    void resize(FrameLayout.LayoutParams params) {
        pdfView.setLayoutParams(params);
    }

    void close(MethodCall call, MethodChannel.Result result) {
        if (pdfView != null) {
            ViewGroup vg = (ViewGroup) (pdfView.getParent());
            vg.removeView(pdfView);
        }
        pdfView = null;
        if (result != null) {
            result.success(null);
        }

        closed = true;
        BasicFlutterPdfViewerPlugin.channel.invokeMethod("onDestroy", null);
    }

    void close() {
        close(null, null);
    }
}
