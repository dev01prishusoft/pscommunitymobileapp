import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class AppPdfViewerPage extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const AppPdfViewerPage({
    Key? key,
    required this.title,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  State<AppPdfViewerPage> createState() => _AppPdfViewerPageState();
}

class _AppPdfViewerPageState extends State<AppPdfViewerPage> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _fetchPdf();
  }

  Future<Uint8List> _fetchPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(LK.couldNotLoadPdf.tr);
      }
    } catch (e) {
      throw Exception(LK.couldNotLoadPdf.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.red),
                    const SizedBox(height: 16),
                    Text(
                      LK.couldNotLoadPdf.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return PdfPreview(
              build: (format) => snapshot.data!,
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              previewPageMargin: EdgeInsets.only(top: 5.h),
              maxPageWidth: MediaQuery.of(context).size.width,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
