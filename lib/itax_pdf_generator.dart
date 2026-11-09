import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_html/html.dart' as uh show AnchorElement;

class ItaxPdfGenerator {
  static Future<void> generatePdf({
    required xls.Workbook workbook,
    required String fileName,
    bool isExportAll = false,
  }) async {
    List<int>? rawPdfBytes;
    String? tempXlsxPath;
    String? tempPdfPath;

    final List<int> excelBytes = workbook.saveAsStream();

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
    } catch (_) {
      rawPdfBytes = null;
    } finally {
      if (tempXlsxPath != null) {
        try {
          final f = File(tempXlsxPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }

    List<int> finalPdfBytes;

    if (rawPdfBytes != null && rawPdfBytes.isNotEmpty) {
      finalPdfBytes = await _stampWatermarkOnPdf(rawPdfBytes);
      if (tempPdfPath != null) {
        try {
          final f = File(tempPdfPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    } else {
      // Fallback: Direct high-fidelity rendering from Excel Workbook
      finalPdfBytes = await generatePdfBytesFromWorkbook(workbook);
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

        final response = await request.send().timeout(const Duration(seconds: 4));
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
          _drawWatermark(page, watermarkLogo);
        }
      }

      final List<int> stampedBytes = document.saveSync();
      document.dispose();
      return stampedBytes;
    } catch (_) {
      return rawPdfBytes;
    }
  }

  static Future<List<int>> generatePdfBytesFromWorkbook(xls.Workbook workbook) async {
    final PdfDocument document = PdfDocument();

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

    for (int sIndex = 0; sIndex < workbook.worksheets.count; sIndex++) {
      final xls.Worksheet sheet = workbook.worksheets[sIndex];

      final PdfSection section = document.sections!.add();
      if (sheet.pageSetup.orientation == xls.ExcelPageOrientation.landscape) {
        section.pageSettings.orientation = PdfPageOrientation.landscape;
      } else {
        section.pageSettings.orientation = PdfPageOrientation.portrait;
      }
      section.pageSettings.size = PdfPageSize.a4;
      section.pageSettings.margins.all = 15;

      final PdfPage page = section.pages.add();

      if (watermarkLogo != null) {
        _drawWatermark(page, watermarkLogo);
      }

      _renderSheetToPage(sheet, page);
    }

    final List<int> pdfBytes = document.saveSync();
    document.dispose();
    return pdfBytes;
  }

  static void _drawWatermark(PdfPage page, PdfBitmap watermarkLogo) {
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

  static void _renderSheetToPage(xls.Worksheet sheet, PdfPage page) {
    final int maxRow = sheet.getLastRow();
    final int maxCol = sheet.getLastColumn();

    if (maxRow <= 0 || maxCol <= 0) return;

    final double pageWidth = page.getClientSize().width;
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: maxCol);

    double totalExcelWidth = 0;
    final List<double> colWidths = [];
    for (int col = 1; col <= maxCol; col++) {
      final double w = sheet.getRangeByIndex(1, col).columnWidth;
      final double safeW = w > 0 ? w : 10.0;
      colWidths.add(safeW);
      totalExcelWidth += safeW;
    }

    for (int col = 0; col < maxCol; col++) {
      grid.columns[col].width = (colWidths[col] / totalExcelWidth) * pageWidth;
    }

    for (int r = 1; r <= maxRow; r++) {
      final PdfGridRow pdfRow = grid.rows.add();
      bool hasRowContent = false;

      for (int c = 1; c <= maxCol; c++) {
        final xls.Range cell = sheet.getRangeByIndex(r, c);
        final String text = cell.displayText.isNotEmpty
            ? cell.displayText
            : (cell.value?.toString() ?? '');

        if (text.isNotEmpty) {
          hasRowContent = true;
        }

        final PdfGridCell pdfCell = pdfRow.cells[c - 1];
        pdfCell.value = text;

        final xls.Style cellStyle = cell.cellStyle;
        final bool isBold = cellStyle.bold;
        final double rawFontSize = cellStyle.fontSize > 0 ? cellStyle.fontSize.toDouble() : 11.0;
        final double pdfFontSize = (rawFontSize * 0.72).clamp(6.5, 12.0);

        pdfCell.style.font = PdfStandardFont(
          PdfFontFamily.helvetica,
          pdfFontSize,
          style: isBold ? PdfFontStyle.bold : PdfFontStyle.regular,
        );

        PdfTextAlignment hAlign = PdfTextAlignment.left;
        if (cellStyle.hAlign == xls.HAlignType.center) {
          hAlign = PdfTextAlignment.center;
        } else if (cellStyle.hAlign == xls.HAlignType.right) {
          hAlign = PdfTextAlignment.right;
        }
        pdfCell.style.stringFormat = PdfStringFormat(
          alignment: hAlign,
          lineAlignment: PdfVerticalAlignment.middle,
        );

        if (cellStyle.backColor.isNotEmpty && cellStyle.backColor != '#FFFFFF' && cellStyle.backColor != '0') {
          final PdfColor? bg = _parseHexColor(cellStyle.backColor);
          if (bg != null) {
            pdfCell.style.backgroundBrush = PdfSolidBrush(bg);
          }
        }

        if (cellStyle.fontColor.isNotEmpty && cellStyle.fontColor != '#000000') {
          final PdfColor? fg = _parseHexColor(cellStyle.fontColor);
          if (fg != null) {
            pdfCell.style.textBrush = PdfSolidBrush(fg);
          }
        }
      }

      if (!hasRowContent) {
        pdfRow.height = 12.0;
      }
    }

    grid.style.cellPadding = PdfPaddings(left: 3, top: 2, right: 3, bottom: 2);
    _applyGridBorders(grid, PdfColor(0, 0, 0));

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 0, pageWidth, page.getClientSize().height),
    );
  }

  static void _applyGridBorders(PdfGrid grid, PdfColor borderColor) {
    final PdfPen pen = PdfPen(borderColor, width: 0.6);
    for (int i = 0; i < grid.rows.count; i++) {
      for (int j = 0; j < grid.columns.count; j++) {
        grid.rows[i].cells[j].style.borders.all = pen;
      }
    }
  }

  static PdfColor? _parseHexColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        int r = int.parse(cleanHex.substring(0, 2), radix: 16);
        int g = int.parse(cleanHex.substring(2, 4), radix: 16);
        int b = int.parse(cleanHex.substring(4, 6), radix: 16);
        return PdfColor(r, g, b);
      }
    } catch (_) {}
    return null;
  }
}
