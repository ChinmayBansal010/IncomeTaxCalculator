import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_html/html.dart' as uh show AnchorElement;

class ItaxPdfGenerator {
  static Future<void> convertExcelBytesToPdf({
    required List<int> excelBytes,
    required String fileName,
    bool isExportAll = false,
  }) async {
    List<int>? rawPdfBytes;
    String? tempXlsxPath;
    String? tempPdfPath;

    try {
      if (!kIsWeb) {
        final Directory tempDir = await getTemporaryDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        tempXlsxPath = '${tempDir.path}/temp_$timestamp.xlsx';
        final File tempXlsxFile = File(tempXlsxPath);
        await tempXlsxFile.writeAsBytes(excelBytes, flush: true);

        final ProcessResult result = await Process.run('libreoffice', [
          '--headless',
          '--convert-to',
          'pdf',
          '--outdir',
          tempDir.path,
          tempXlsxPath,
        ]);

        tempPdfPath = '${tempDir.path}/temp_$timestamp.pdf';
        final File tempPdfFile = File(tempPdfPath);

        if (result.exitCode == 0 && await tempPdfFile.exists()) {
          rawPdfBytes = await tempPdfFile.readAsBytes();
        } else {
          rawPdfBytes = await _convertViaServer(excelBytes, fileName);
        }
      } else {
        rawPdfBytes = await _convertViaServer(excelBytes, fileName);
      }
    } catch (e) {
      rawPdfBytes = await _convertViaServer(excelBytes, fileName);
    } finally {
      if (tempXlsxPath != null) {
        try {
          final f = File(tempXlsxPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }

    if (rawPdfBytes == null || rawPdfBytes.isEmpty) {
      throw Exception('Excel-to-PDF conversion failed. Please ensure LibreOffice or conversion service is running.');
    }

    final List<int> finalPdfBytes = await _stampWatermarkOnPdf(rawPdfBytes);

    if (tempPdfPath != null) {
      try {
        final f = File(tempPdfPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }

    final String pdfFileName = "$fileName.pdf";
    if (kIsWeb) {
      final base64Pdf = base64Encode(finalPdfBytes);
      uh.AnchorElement(href: 'data:application/pdf;base64,$base64Pdf')
        ..setAttribute('download', pdfFileName)
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filePath = '$path/$pdfFileName';
      final File file = File(filePath);
      await file.writeAsBytes(finalPdfBytes, flush: true);
      if (!isExportAll) {
        OpenFile.open(filePath);
      }
    }
  }

  static Future<List<int>?> _convertViaServer(List<int> excelBytes, String fileName) async {
    final List<String> serverUris = [
      "http://127.0.0.1:5000/convert",
      "http://192.168.1.36:5000/convert",
    ];

    for (final uriStr in serverUris) {
      try {
        final uri = Uri.parse(uriStr);
        final request = http.MultipartRequest("POST", uri);
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          excelBytes,
          filename: "$fileName.xlsx",
          contentType: MediaType("application", "vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
        ));

        final response = await request.send().timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          return await response.stream.toBytes();
        }
      } catch (_) {}
    }
    return null;
  }

  static Future<List<int>> _stampWatermarkOnPdf(List<int> rawPdfBytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: rawPdfBytes);

      PdfBitmap? watermarkLogo;
      try {
        final ByteData logoData = await rootBundle.load('assets/images/mcd_logo.png');
        watermarkLogo = PdfBitmap(logoData.buffer.asUint8List());
      } catch (_) {
        try {
          final ByteData logoData = await rootBundle.load('assets/icon.png');
          watermarkLogo = PdfBitmap(logoData.buffer.asUint8List());
        } catch (_) {}
      }

      if (watermarkLogo != null) {
        for (int i = 0; i < document.pages.count; i++) {
          final PdfPage page = document.pages[i];
          final PdfGraphics graphics = page.graphics;
          final Size pageSize = page.getClientSize();

          graphics.save();
          graphics.setTransparency(0.08);

          double imageWidth = pageSize.width * 0.45;
          double imageHeight = imageWidth * (watermarkLogo.height / watermarkLogo.width);
          if (imageHeight > pageSize.height * 0.55) {
            imageHeight = pageSize.height * 0.55;
            imageWidth = imageHeight * (watermarkLogo.width / watermarkLogo.height);
          }

          double x = (pageSize.width - imageWidth) / 2;
          double y = (pageSize.height - imageHeight) / 2;

          graphics.drawImage(watermarkLogo, Rect.fromLTWH(x, y, imageWidth, imageHeight));
          graphics.restore();
        }
      }

      final List<int> stampedBytes = document.saveSync();
      document.dispose();
      return stampedBytes;
    } catch (_) {
      return rawPdfBytes;
    }
  }
}
