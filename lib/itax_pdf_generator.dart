import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_html/html.dart' as uh show AnchorElement;
import 'shared.dart';

class ItaxPdfGenerator {
  static Future<void> generateAndDownloadPdf({
    required String biometricId,
    required Map<String, dynamic> mainpgData,
    required Map<String, Map<String?, dynamic>> monthdata,
    required Map<String, dynamic> dedData,
    required Map<String, dynamic> arrData,
    required Map<String, dynamic> itaxData,
    required Map<String, dynamic> itaxnewData,
    required Map<String, dynamic> itaxoldData,
    required String fileName,
    bool isExportAll = false,
  }) async {
    final PdfDocument document = PdfDocument();

    // Load MCD Logo for watermark
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

    // Set page template watermark for all pages
    if (watermarkLogo != null) {
      document.template.top = _createWatermarkTemplate(watermarkLogo);
    }

    // Fonts & Styles
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont sectionHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont gridHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
    final PdfFont cellFont = PdfStandardFont(PdfFontFamily.helvetica, 8.5, style: PdfFontStyle.regular);
    final PdfFont cellFontBold = PdfStandardFont(PdfFontFamily.helvetica, 8.5, style: PdfFontStyle.bold);

    // Colors
    final PdfColor headerBgColor = PdfColor(241, 245, 249);
    final PdfColor borderGridColor = PdfColor(203, 213, 225);
    final PdfColor totalRowBgColor = PdfColor(207, 210, 239);
    final PdfColor textColor = PdfColor(15, 23, 42);

    // =========================================================================
    // PAGE 1: ITAX FORM / ECR MATRIX (Landscape)
    // =========================================================================
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 20;

    PdfPage page1 = document.pages.add();
    double y = 0;

    // Header Title
    final PdfTextElement titleElement = PdfTextElement(
      text: sharedData.zone.toUpperCase(),
      font: titleFont,
      brush: PdfSolidBrush(PdfColor(30, 58, 138)),
    );
    final PdfLayoutResult titleResult = titleElement.draw(page: page1, bounds: Rect.fromLTWH(0, y, page1.getClientSize().width, 24))!;
    y = titleResult.bounds.bottom + 10;

    // Employee Information Table (Grid)
    final PdfGrid empGrid = PdfGrid();
    empGrid.columns.add(count: 4);
    empGrid.columns[0].width = 110;
    empGrid.columns[1].width = 220;
    empGrid.columns[2].width = 110;

    _addGridRow(empGrid, ["BIOMETRIC ID", biometricId, "NAME", (mainpgData['name'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["FATHER/HUSBAND NAME", (mainpgData['fhname'] ?? '').toString(), "SEX", (mainpgData['sex'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["DESIGNATION", (mainpgData['designation'] ?? '').toString(), "GROUP", (mainpgData['group'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["EMPLOYEE TYPE", (mainpgData['emptype'] ?? '').toString(), "PAY SCALE", (mainpgData['payscale'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["DATE OF BIRTH", (mainpgData['dob'] ?? '').toString(), "PAN NO.", (mainpgData['panno'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["MOBILE NO.", (mainpgData['mobileno'] ?? '').toString(), "GPF/NPS NO.", (mainpgData['gpfno'] ?? mainpgData['npsno'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["PLACE OF DUTY", (mainpgData['place'] ?? '').toString(), "ADDRESS", (mainpgData['address'] ?? '').toString()], cellFontBold, cellFont);

    empGrid.style.cellPadding = PdfPaddings(left: 6, top: 4, right: 6, bottom: 4);
    _applyGridBorders(empGrid, borderGridColor);

    final PdfLayoutResult empResult = empGrid.draw(page: page1, bounds: Rect.fromLTWH(0, y, 0, 0))!;
    y = empResult.bounds.bottom + 15;

    // ECR Complete Matrix Table
    final PdfTextElement matrixHeader = PdfTextElement(
      text: "MONTHLY SALARY & DEDUCTION MATRIX",
      font: sectionHeaderFont,
      brush: PdfSolidBrush(PdfColor(15, 23, 42)),
    );
    final PdfLayoutResult matrixHeaderResult = matrixHeader.draw(page: page1, bounds: Rect.fromLTWH(0, y, 0, 0))!;
    y = matrixHeaderResult.bounds.bottom + 6;

    final PdfGrid matrixGrid = PdfGrid();
    matrixGrid.columns.add(count: 11);

    final List<String> matrixCols = [
      "PERIOD", "BASIC PAY", "DA", "HRA", "OTHER ALLOW", "GROSS", "INC TAX", "GPF/NPS", "OTHER DED", "TOTAL DED", "NET SALARY"
    ];

    final PdfGridRow headerRow = matrixGrid.headers.add(1)[0];
    for (int i = 0; i < matrixCols.length; i++) {
      headerRow.cells[i].value = matrixCols[i];
      headerRow.cells[i].style.backgroundBrush = PdfSolidBrush(PdfColor(15, 23, 42));
      headerRow.cells[i].style.textBrush = PdfBrushes.white;
      headerRow.cells[i].style.font = gridHeaderFont;
      headerRow.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

    // Populate 12 Months + Quarter Totals
    const months = ['mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec', 'jan', 'feb'];
    final yearStr = sharedData.ccurrentYear.replaceAll('20', '');

    int quarterIndex = 1;
    for (int i = 0; i < months.length; i++) {
      final mKey = months[i];
      final mData = monthdata[mKey] ?? {};
      final label = "${mKey.toUpperCase()} - $yearStr";

      final bp = _toInt(mData['bp']);
      final da = _toInt(mData['da']);
      final hra = _toInt(mData['hra']);
      final otherAllow = _toInt(mData['npa']) + _toInt(mData['splpay']) + _toInt(mData['conv']) + _toInt(mData['pg']) + _toInt(mData['annual']) + _toInt(mData['uniform']) + _toInt(mData['nursing']) + _toInt(mData['ta']) + _toInt(mData['daonta']) + _toInt(mData['medical']) + _toInt(mData['dirt']) + _toInt(mData['washing']) + _toInt(mData['tb']) + _toInt(mData['night']) + _toInt(mData['drive']) + _toInt(mData['cycle']) + _toInt(mData['pca']);
      final gross = _toInt(mData['gross']);
      final it = _toInt(mData['incometax']);
      final gpfNps = _toInt(mData['gpf']) + _toInt(mData['nps']);
      final otherDed = _toInt(mData['gis']) + _toInt(mData['epf']) + _toInt(mData['esi']) + _toInt(mData['slf']) + _toInt(mData['society']) + _toInt(mData['recovery']) + _toInt(mData['wf']) + _toInt(mData['other']);
      final totalDed = _toInt(mData['totalded']);
      final net = _toInt(mData['netsalary']);

      _addMatrixRow(matrixGrid, [
        label, bp.toString(), da.toString(), hra.toString(), otherAllow.toString(),
        gross.toString(), it.toString(), gpfNps.toString(), otherDed.toString(),
        totalDed.toString(), net.toString()
      ], cellFont, isTotal: false);

      if ((i + 1) % 3 == 0) {
        _addMatrixRow(matrixGrid, [
          "QTR - $quarterIndex TOTAL", "", "", "", "", "", "", "", "", "", ""
        ], cellFontBold, isTotal: true, totalBg: totalRowBgColor);
        quarterIndex++;
      }
    }

    matrixGrid.style.cellPadding = PdfPaddings(left: 4, top: 3, right: 4, bottom: 3);
    _applyGridBorders(matrixGrid, borderGridColor);
    matrixGrid.draw(page: page1, bounds: Rect.fromLTWH(0, y, 0, 0));

    // =========================================================================
    // PAGE 2: TAX COMPUTATION STATEMENT (Portrait)
    // =========================================================================
    document.pageSettings.orientation = PdfPageOrientation.portrait;
    document.pageSettings.size = PdfPageSize.a4;

    PdfPage page2 = document.pages.add();
    y = 0;

    final PdfTextElement page2Header = PdfTextElement(
      text: "TAX COMPUTATION STATEMENT (${sharedData.ccurrentYear})",
      font: titleFont,
      brush: PdfSolidBrush(PdfColor(30, 58, 138)),
    );
    final PdfLayoutResult p2HeaderResult = page2Header.draw(page: page2, bounds: Rect.fromLTWH(0, y, 0, 0))!;
    y = p2HeaderResult.bounds.bottom + 12;

    // Summary Table (New vs Old Tax Regime)
    final PdfGrid summaryGrid = PdfGrid();
    summaryGrid.columns.add(count: 3);
    summaryGrid.columns[0].width = 240;

    final PdfGridRow sHeader = summaryGrid.headers.add(1)[0];
    sHeader.cells[0].value = "PARTICULARS";
    sHeader.cells[1].value = "NEW REGIME";
    sHeader.cells[2].value = "OLD REGIME";
    for (int i = 0; i < 3; i++) {
      sHeader.cells[i].style.backgroundBrush = PdfSolidBrush(headerBgColor);
      sHeader.cells[i].style.font = gridHeaderFont;
      sHeader.cells[i].style.textBrush = PdfSolidBrush(textColor);
    }

    final newTtp = _toInt(itaxnewData['ttp']);
    final oldTtp = _toInt(itaxoldData['ttp']);
    final newNitpi = _toInt(itaxnewData['nitpi']);
    final oldNitpi = _toInt(itaxoldData['nitpi']);
    final newExcess = _toInt(itaxnewData['ep']);
    final oldExcess = _toInt(itaxoldData['ep']);
    final deduct = _toInt(itaxnewData['deduct']);

    _addGridRow(summaryGrid, ["Total Tax Payable", "Rs. $newTtp", "Rs. $oldTtp"], cellFontBold, cellFont);
    _addGridRow(summaryGrid, ["Tax Already Deducted (TDS)", "Rs. $deduct", "Rs. $deduct"], cellFontBold, cellFont);
    _addGridRow(summaryGrid, ["Net Tax Payable / (Balance)", "Rs. $newNitpi", "Rs. $oldNitpi"], cellFontBold, cellFont);
    _addGridRow(summaryGrid, ["Excess Tax Paid", "Rs. $newExcess", "Rs. $oldExcess"], cellFontBold, cellFont);

    summaryGrid.style.cellPadding = PdfPaddings(left: 8, top: 5, right: 8, bottom: 5);
    _applyGridBorders(summaryGrid, borderGridColor);
    final PdfLayoutResult sGridResult = summaryGrid.draw(page: page2, bounds: Rect.fromLTWH(0, y, 0, 0))!;
    y = sGridResult.bounds.bottom + 20;

    // Detailed Deductions & Exemptions Breakdown Table
    final PdfTextElement dedHeader = PdfTextElement(
      text: "DEDUCTIONS & EXEMPTIONS SUMMARY",
      font: sectionHeaderFont,
      brush: PdfSolidBrush(textColor),
    );
    final PdfLayoutResult dedHeaderResult = dedHeader.draw(page: page2, bounds: Rect.fromLTWH(0, y, 0, 0))!;
    y = dedHeaderResult.bounds.bottom + 8;

    final PdfGrid breakdownGrid = PdfGrid();
    breakdownGrid.columns.add(count: 2);
    breakdownGrid.columns[0].width = 320;

    _addGridRow(breakdownGrid, ["80C Savings Total", "Rs. ${_toInt(dedData['totalsav'])}"], cellFont, cellFontBold);
    _addGridRow(breakdownGrid, ["80C Max Eligible", "Rs. ${_toInt(dedData['maxsav'])}"], cellFont, cellFontBold);
    _addGridRow(breakdownGrid, ["80CCD(1B) NPS Additional", "Rs. ${_toInt(dedData['80ccdnps'])}"], cellFont, cellFontBold);
    _addGridRow(breakdownGrid, ["80D Mediclaim Health Insurance", "Rs. ${_toInt(dedData['80d'])}"], cellFont, cellFontBold);
    _addGridRow(breakdownGrid, ["Housing Loan Interest (Sec 24)", "Rs. ${_toInt(dedData['hli'])}"], cellFont, cellFontBold);
    _addGridRow(breakdownGrid, ["80G Donations", "Rs. ${_toInt(dedData['80g'])}"], cellFont, cellFontBold);
    _addGridRow(breakdownGrid, ["Relief u/s 89", "Rs. ${_toInt(dedData['relief'])}"], cellFont, cellFontBold);

    breakdownGrid.style.cellPadding = PdfPaddings(left: 8, top: 5, right: 8, bottom: 5);
    _applyGridBorders(breakdownGrid, borderGridColor);
    breakdownGrid.draw(page: page2, bounds: Rect.fromLTWH(0, y, 0, 0));

    // Save and Output PDF Bytes
    final List<int> pdfBytes = document.saveSync();
    document.dispose();

    final String pdfFileName = "$fileName.pdf";

    if (kIsWeb) {
      final base64Pdf = base64Encode(pdfBytes);
      uh.AnchorElement(href: 'data:application/pdf;base64,$base64Pdf')
        ..setAttribute('download', pdfFileName)
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filePath = '$path/$pdfFileName';
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);
      if (!isExportAll) {
        OpenFile.open(filePath);
      }
    }
  }

  static PdfPageTemplateElement _createWatermarkTemplate(PdfBitmap watermarkImage) {
    // Standard A4 landscape size 842 x 595
    const Size templateSize = Size(842, 595);
    final PdfPageTemplateElement template = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, templateSize.width, templateSize.height),
    );

    final PdfGraphics graphics = template.graphics;
    graphics.save();
    graphics.setTransparency(0.09); // Subtle background watermark

    double imageWidth = 320;
    double imageHeight = imageWidth * (watermarkImage.height / watermarkImage.width);

    double x = (templateSize.width - imageWidth) / 2;
    double y = (templateSize.height - imageHeight) / 2;

    graphics.drawImage(watermarkImage, Rect.fromLTWH(x, y, imageWidth, imageHeight));
    graphics.restore();

    return template;
  }

  static void _addGridRow(PdfGrid grid, List<String> values, PdfFont headerFont, PdfFont valueFont) {
    final PdfGridRow row = grid.rows.add();
    for (int i = 0; i < values.length; i++) {
      row.cells[i].value = values[i];
      row.cells[i].style.font = (i % 2 == 0) ? headerFont : valueFont;
    }
  }

  static void _addMatrixRow(PdfGrid grid, List<String> values, PdfFont font, {bool isTotal = false, PdfColor? totalBg}) {
    final PdfGridRow row = grid.rows.add();
    for (int i = 0; i < values.length; i++) {
      row.cells[i].value = values[i];
      row.cells[i].style.font = font;
      if (isTotal && totalBg != null) {
        row.cells[i].style.backgroundBrush = PdfSolidBrush(totalBg);
      }
      if (i > 0) {
        row.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      }
    }
  }

  static void _applyGridBorders(PdfGrid grid, PdfColor borderColor) {
    final PdfPen pen = PdfPen(borderColor, width: 0.8);
    for (int i = 0; i < grid.rows.count; i++) {
      for (int j = 0; j < grid.columns.count; j++) {
        grid.rows[i].cells[j].style.borders.all = pen;
      }
    }
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    return int.tryParse(val.toString().replaceAll(',', '').trim()) ?? 0;
  }
}
