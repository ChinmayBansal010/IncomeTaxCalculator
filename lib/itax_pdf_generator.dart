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

    // Common Colors matching Excel styles
    final PdfColor borderGridColor = PdfColor(0, 0, 0);
    final PdfColor otherHeaderBgBlue = PdfColor(142, 180, 226); // #8EB4E2
    final PdfColor tableHeadingBg = PdfColor(238, 236, 225); // #EEECE1
    final PdfColor totalRowBgOrange = PdfColor(250, 191, 143); // #FABF8F
    final PdfColor textColor = PdfColor(0, 0, 0);

    // Common Fonts
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final PdfFont sectionHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont gridHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
    final PdfFont cellFont = PdfStandardFont(PdfFontFamily.helvetica, 8.5, style: PdfFontStyle.regular);
    final PdfFont cellFontBold = PdfStandardFont(PdfFontFamily.helvetica, 8.5, style: PdfFontStyle.bold);
    final PdfFont cellFontLargeBold = PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    // Helper for adding watermark to a page
    void addWatermarkToPage(PdfPage page) {
      if (watermarkLogo == null) return;
      final PdfGraphics graphics = page.graphics;
      final Size pageSize = page.getClientSize();

      graphics.save();
      graphics.setTransparency(0.08);

      double imageWidth = pageSize.width * 0.45;
      double imageHeight = imageWidth * (watermarkLogo.height / watermarkLogo.width);

      double x = (pageSize.width - imageWidth) / 2;
      double y = (pageSize.height - imageHeight) / 2;

      graphics.drawImage(watermarkLogo, Rect.fromLTWH(x, y, imageWidth, imageHeight));
      graphics.restore();
    }

    // =========================================================================
    // SECTION 1: ITAX FORM SHEET (Landscape A4)
    // =========================================================================
    PdfSection section1 = document.sections!.add();
    section1.pageSettings.orientation = PdfPageOrientation.landscape;
    section1.pageSettings.size = PdfPageSize.a4;
    section1.pageSettings.margins.all = 20;

    PdfPage page1 = section1.pages.add();
    addWatermarkToPage(page1);

    double y1 = 0;
    final double landscapeWidth = page1.getClientSize().width;

    // Title Banner
    final PdfTextElement title1 = PdfTextElement(
      text: sharedData.zone.toUpperCase(),
      font: titleFont,
      brush: PdfSolidBrush(textColor),
    );
    final PdfLayoutResult titleResult1 = title1.draw(
      page: page1,
      bounds: Rect.fromLTWH(0, y1, landscapeWidth, 20),
    )!;
    y1 = titleResult1.bounds.bottom + 8;

    // Employee Meta Grid (Landscape)
    final PdfGrid empGrid = PdfGrid();
    empGrid.columns.add(count: 6);
    empGrid.columns[0].width = 95;
    empGrid.columns[1].width = 160;
    empGrid.columns[2].width = 95;
    empGrid.columns[3].width = 160;
    empGrid.columns[4].width = 95;
    empGrid.columns[5].width = landscapeWidth - (95 + 160 + 95 + 160 + 95);

    _addGridRow(empGrid, ["BIOMETRIC ID", biometricId, "NAME", (mainpgData['name'] ?? '').toString(), "F/H NAME", (mainpgData['fhname'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["SEX", (mainpgData['sex'] ?? '').toString(), "DESIGNATION", (mainpgData['designation'] ?? '').toString(), "GROUP", (mainpgData['group'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["PAY SCALE", (mainpgData['payscale'] ?? '').toString(), "EMPLOYEE TYPE", (mainpgData['emptype'] ?? '').toString(), "DOB", (mainpgData['dob'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["PAN NO.", (mainpgData['panno'] ?? '').toString(), "MOBILE NO.", (mainpgData['mobileno'] ?? '').toString(), "GPF/NPS NO.", (mainpgData['gpfno'] ?? mainpgData['npsno'] ?? '').toString()], cellFontBold, cellFont);
    _addGridRow(empGrid, ["LEVEL", (mainpgData['level'] ?? '').toString(), "PLACE OF DUTY", (mainpgData['place'] ?? '').toString(), "ADDRESS", (mainpgData['address'] ?? '').toString()], cellFontBold, cellFont);

    empGrid.style.cellPadding = PdfPaddings(left: 4, top: 2.5, right: 4, bottom: 2.5);
    _applyGridBorders(empGrid, borderGridColor);

    final PdfLayoutResult empResult = empGrid.draw(
      page: page1,
      bounds: Rect.fromLTWH(0, y1, landscapeWidth, 0),
    )!;
    y1 = empResult.bounds.bottom + 10;

    // 11-Column Monthly Salary & Deduction Matrix Table
    final PdfGrid matrixGrid = PdfGrid();
    matrixGrid.columns.add(count: 11);

    final colWidths = [90.0, 65.0, 55.0, 55.0, 75.0, 65.0, 65.0, 65.0, 70.0, 70.0, 85.0];
    for (int i = 0; i < colWidths.length; i++) {
      matrixGrid.columns[i].width = colWidths[i];
    }

    final List<String> matrixCols = [
      "PERIOD", "BASIC PAY", "DA", "HRA", "OTHER ALLOW", "GROSS", "INC TAX", "GPF/NPS", "OTHER DED", "TOTAL DED", "NET SALARY"
    ];

    final PdfGridRow headerRow = matrixGrid.headers.add(1)[0];
    for (int i = 0; i < matrixCols.length; i++) {
      headerRow.cells[i].value = matrixCols[i];
      headerRow.cells[i].style.backgroundBrush = PdfSolidBrush(tableHeadingBg);
      headerRow.cells[i].style.textBrush = PdfSolidBrush(textColor);
      headerRow.cells[i].style.font = gridHeaderFont;
      headerRow.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

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
        ], cellFontBold, isTotal: true, totalBg: totalRowBgOrange);
        quarterIndex++;
      }
    }

    matrixGrid.style.cellPadding = PdfPaddings(left: 3, top: 2, right: 3, bottom: 2);
    _applyGridBorders(matrixGrid, borderGridColor);
    matrixGrid.draw(
      page: page1,
      bounds: Rect.fromLTWH(0, y1, landscapeWidth, page1.getClientSize().height - y1),
    );

    // =========================================================================
    // SECTION 2: COMPUTATION SHEET (Portrait A4)
    // =========================================================================
    PdfSection section2 = document.sections!.add();
    section2.pageSettings.orientation = PdfPageOrientation.portrait;
    section2.pageSettings.size = PdfPageSize.a4;
    section2.pageSettings.margins.all = 20;

    PdfPage page2 = section2.pages.add();
    addWatermarkToPage(page2);

    double y2 = 0;
    final double portraitWidth = page2.getClientSize().width;

    // Header Banner
    final PdfTextElement headerComp = PdfTextElement(
      text: "COMPUTATION OF TOTAL INCOME (${sharedData.ccurrentYear})",
      font: titleFont,
      brush: PdfSolidBrush(textColor),
    );
    final PdfLayoutResult compTitleResult = headerComp.draw(
      page: page2,
      bounds: Rect.fromLTWH(0, y2, portraitWidth, 22),
    )!;
    y2 = compTitleResult.bounds.bottom + 8;

    // Employee Name & ID Bar
    final PdfGrid barGrid = PdfGrid();
    barGrid.columns.add(count: 2);
    barGrid.columns[0].width = portraitWidth * 0.65;
    barGrid.columns[1].width = portraitWidth * 0.35;
    _addGridRow(barGrid, ["NAME: ${(mainpgData['name'] ?? '').toString()}", "BIOMETRIC ID: $biometricId"], cellFontBold, cellFontBold);
    barGrid.style.cellPadding = PdfPaddings(left: 6, top: 4, right: 6, bottom: 4);
    _applyGridBorders(barGrid, borderGridColor);
    final PdfLayoutResult barResult = barGrid.draw(page: page2, bounds: Rect.fromLTWH(0, y2, portraitWidth, 0))!;
    y2 = barResult.bounds.bottom + 10;

    // Tax Computation Summary Table
    final PdfGrid compGrid = PdfGrid();
    compGrid.columns.add(count: 3);
    compGrid.columns[0].width = portraitWidth * 0.50;
    compGrid.columns[1].width = portraitWidth * 0.25;
    compGrid.columns[2].width = portraitWidth * 0.25;

    final PdfGridRow cHeader = compGrid.headers.add(1)[0];
    cHeader.cells[0].value = "PARTICULARS";
    cHeader.cells[1].value = "NEW REGIME";
    cHeader.cells[2].value = "OLD REGIME";
    for (int i = 0; i < 3; i++) {
      cHeader.cells[i].style.backgroundBrush = PdfSolidBrush(otherHeaderBgBlue);
      cHeader.cells[i].style.font = gridHeaderFont;
      cHeader.cells[i].style.textBrush = PdfSolidBrush(textColor);
      cHeader.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

    final newTtp = _toInt(itaxnewData['ttp']);
    final oldTtp = _toInt(itaxoldData['ttp']);
    final newNitpi = _toInt(itaxnewData['nitpi']);
    final oldNitpi = _toInt(itaxoldData['nitpi']);
    final newExcess = _toInt(itaxnewData['ep']);
    final oldExcess = _toInt(itaxoldData['ep']);
    final deduct = _toInt(itaxnewData['deduct']);

    _addGridRow(compGrid, ["Total Tax Payable", "Rs. $newTtp", "Rs. $oldTtp"], cellFontBold, cellFont);
    _addGridRow(compGrid, ["Tax Already Deducted (TDS)", "Rs. $deduct", "Rs. $deduct"], cellFontBold, cellFont);
    _addGridRow(compGrid, ["Net Tax Payable / (Balance)", "Rs. $newNitpi", "Rs. $oldNitpi"], cellFontBold, cellFont);
    _addGridRow(compGrid, ["Excess Tax Paid", "Rs. $newExcess", "Rs. $oldExcess"], cellFontBold, cellFont);

    compGrid.style.cellPadding = PdfPaddings(left: 6, top: 4, right: 6, bottom: 4);
    _applyGridBorders(compGrid, borderGridColor);
    final PdfLayoutResult compResult = compGrid.draw(page: page2, bounds: Rect.fromLTWH(0, y2, portraitWidth, 0))!;
    y2 = compResult.bounds.bottom + 12;

    // Deductions Summary Grid
    final PdfTextElement dedTitle = PdfTextElement(
      text: "DEDUCTIONS & SAVINGS BREAKDOWN",
      font: sectionHeaderFont,
      brush: PdfSolidBrush(textColor),
    );
    final PdfLayoutResult dedTitleResult = dedTitle.draw(page: page2, bounds: Rect.fromLTWH(0, y2, portraitWidth, 0))!;
    y2 = dedTitleResult.bounds.bottom + 6;

    final PdfGrid dedGrid = PdfGrid();
    dedGrid.columns.add(count: 2);
    dedGrid.columns[0].width = portraitWidth * 0.65;
    dedGrid.columns[1].width = portraitWidth * 0.35;

    _addGridRow(dedGrid, ["80C Savings Total", "Rs. ${_toInt(dedData['totalsav'])}"], cellFont, cellFontBold);
    _addGridRow(dedGrid, ["80C Max Eligible Limit", "Rs. ${_toInt(dedData['maxsav'])}"], cellFont, cellFontBold);
    _addGridRow(dedGrid, ["80CCD(1B) NPS Additional", "Rs. ${_toInt(dedData['80ccdnps'])}"], cellFont, cellFontBold);
    _addGridRow(dedGrid, ["80D Mediclaim Health Insurance", "Rs. ${_toInt(dedData['80d'])}"], cellFont, cellFontBold);
    _addGridRow(dedGrid, ["Housing Loan Interest (Sec 24)", "Rs. ${_toInt(dedData['hli'])}"], cellFont, cellFontBold);
    _addGridRow(dedGrid, ["80G Donations", "Rs. ${_toInt(dedData['80g'])}"], cellFont, cellFontBold);
    _addGridRow(dedGrid, ["Relief u/s 89", "Rs. ${_toInt(dedData['relief'])}"], cellFont, cellFontBold);

    dedGrid.style.cellPadding = PdfPaddings(left: 6, top: 3.5, right: 6, bottom: 3.5);
    _applyGridBorders(dedGrid, borderGridColor);
    dedGrid.draw(page: page2, bounds: Rect.fromLTWH(0, y2, portraitWidth, page2.getClientSize().height - y2));

    // =========================================================================
    // SECTION 3: ITAX CALC-NEW SHEET (Portrait A4)
    // =========================================================================
    PdfSection section3 = document.sections!.add();
    section3.pageSettings.orientation = PdfPageOrientation.portrait;
    section3.pageSettings.size = PdfPageSize.a4;
    section3.pageSettings.margins.all = 20;

    PdfPage page3 = section3.pages.add();
    addWatermarkToPage(page3);

    double y3 = 0;
    final PdfTextElement newHeader = PdfTextElement(
      text: "NEW TAX REGIME CALCULATION STATEMENT (${sharedData.ccurrentYear})",
      font: titleFont,
      brush: PdfSolidBrush(textColor),
    );
    final PdfLayoutResult newHeaderResult = newHeader.draw(page: page3, bounds: Rect.fromLTWH(0, y3, portraitWidth, 22))!;
    y3 = newHeaderResult.bounds.bottom + 10;

    final PdfGrid newGrid = PdfGrid();
    newGrid.columns.add(count: 3);
    newGrid.columns[0].width = portraitWidth * 0.50;
    newGrid.columns[1].width = portraitWidth * 0.25;
    newGrid.columns[2].width = portraitWidth * 0.25;

    final PdfGridRow nHeader = newGrid.headers.add(1)[0];
    nHeader.cells[0].value = "INCOME SLABS";
    nHeader.cells[1].value = "TAX RATE";
    nHeader.cells[2].value = "TAX AMOUNT";
    for (int i = 0; i < 3; i++) {
      nHeader.cells[i].style.backgroundBrush = PdfSolidBrush(otherHeaderBgBlue);
      nHeader.cells[i].style.font = gridHeaderFont;
      nHeader.cells[i].style.textBrush = PdfSolidBrush(textColor);
      nHeader.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

    _addGridRow(newGrid, ["Up to Rs. 3,00,000", "0%", "Nil"], cellFont, cellFontBold);
    _addGridRow(newGrid, ["Rs. 3,00,001 to Rs. 6,00,000", "5%", "Rs. ${_toInt(itaxnewData['tax5'])}"], cellFont, cellFontBold);
    _addGridRow(newGrid, ["Rs. 6,00,001 to Rs. 9,00,000", "10%", "Rs. ${_toInt(itaxnewData['tax10'])}"], cellFont, cellFontBold);
    _addGridRow(newGrid, ["Rs. 9,00,001 to Rs. 12,00,000", "15%", "Rs. ${_toInt(itaxnewData['tax15'])}"], cellFont, cellFontBold);
    _addGridRow(newGrid, ["Rs. 12,00,001 to Rs. 15,00,000", "20%", "Rs. ${_toInt(itaxnewData['tax20'])}"], cellFont, cellFontBold);
    _addGridRow(newGrid, ["Above Rs. 15,00,000", "30%", "Rs. ${_toInt(itaxnewData['tax30'])}"], cellFont, cellFontBold);
    _addGridRow(newGrid, ["Standard Deduction", "-", "Rs. 75,000"], cellFontBold, cellFontBold);
    _addGridRow(newGrid, ["Health & Education Cess (4%)", "4%", "Rs. ${_toInt(itaxnewData['cess'])}"], cellFontBold, cellFontBold);
    _addGridRow(newGrid, ["Total Tax Payable (New Regime)", "-", "Rs. $newTtp"], cellFontLargeBold, cellFontLargeBold);

    newGrid.style.cellPadding = PdfPaddings(left: 6, top: 4, right: 6, bottom: 4);
    _applyGridBorders(newGrid, borderGridColor);
    newGrid.draw(page: page3, bounds: Rect.fromLTWH(0, y3, portraitWidth, page3.getClientSize().height - y3));

    // =========================================================================
    // SECTION 4: ITAX CAL-OLD SHEET (Portrait A4)
    // =========================================================================
    PdfSection section4 = document.sections!.add();
    section4.pageSettings.orientation = PdfPageOrientation.portrait;
    section4.pageSettings.size = PdfPageSize.a4;
    section4.pageSettings.margins.all = 20;

    PdfPage page4 = section4.pages.add();
    addWatermarkToPage(page4);

    double y4 = 0;
    final PdfTextElement oldHeader = PdfTextElement(
      text: "OLD TAX REGIME CALCULATION STATEMENT (${sharedData.ccurrentYear})",
      font: titleFont,
      brush: PdfSolidBrush(textColor),
    );
    final PdfLayoutResult oldHeaderResult = oldHeader.draw(page: page4, bounds: Rect.fromLTWH(0, y4, portraitWidth, 22))!;
    y4 = oldHeaderResult.bounds.bottom + 10;

    final PdfGrid oldGrid = PdfGrid();
    oldGrid.columns.add(count: 3);
    oldGrid.columns[0].width = portraitWidth * 0.50;
    oldGrid.columns[1].width = portraitWidth * 0.25;
    oldGrid.columns[2].width = portraitWidth * 0.25;

    final PdfGridRow oHeader = oldGrid.headers.add(1)[0];
    oHeader.cells[0].value = "INCOME SLABS";
    oHeader.cells[1].value = "TAX RATE";
    oHeader.cells[2].value = "TAX AMOUNT";
    for (int i = 0; i < 3; i++) {
      oHeader.cells[i].style.backgroundBrush = PdfSolidBrush(otherHeaderBgBlue);
      oHeader.cells[i].style.font = gridHeaderFont;
      oHeader.cells[i].style.textBrush = PdfSolidBrush(textColor);
      oHeader.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

    _addGridRow(oldGrid, ["Up to Rs. 2,50,000", "0%", "Nil"], cellFont, cellFontBold);
    _addGridRow(oldGrid, ["Rs. 2,50,001 to Rs. 5,00,000", "5%", "Rs. ${_toInt(itaxoldData['tax5'])}"], cellFont, cellFontBold);
    _addGridRow(oldGrid, ["Rs. 5,00,001 to Rs. 10,00,000", "20%", "Rs. ${_toInt(itaxoldData['tax20'])}"], cellFont, cellFontBold);
    _addGridRow(oldGrid, ["Above Rs. 10,00,000", "30%", "Rs. ${_toInt(itaxoldData['tax30'])}"], cellFont, cellFontBold);
    _addGridRow(oldGrid, ["Standard Deduction", "-", "Rs. 50,000"], cellFontBold, cellFontBold);
    _addGridRow(oldGrid, ["Chapter VI-A Total Deductions", "-", "Rs. ${_toInt(itaxoldData['totded'])}"], cellFontBold, cellFontBold);
    _addGridRow(oldGrid, ["Health & Education Cess (4%)", "4%", "Rs. ${_toInt(itaxoldData['cess'])}"], cellFontBold, cellFontBold);
    _addGridRow(oldGrid, ["Total Tax Payable (Old Regime)", "-", "Rs. $oldTtp"], cellFontLargeBold, cellFontLargeBold);

    oldGrid.style.cellPadding = PdfPaddings(left: 6, top: 4, right: 6, bottom: 4);
    _applyGridBorders(oldGrid, borderGridColor);
    oldGrid.draw(page: page4, bounds: Rect.fromLTWH(0, y4, portraitWidth, page4.getClientSize().height - y4));

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

  static void _addGridRow(PdfGrid grid, List<String> values, PdfFont headerFont, PdfFont valueFont) {
    final PdfGridRow row = grid.rows.add();
    for (int i = 0; i < values.length; i++) {
      row.cells[i].value = values[i];
      row.cells[i].style.font = (i % 2 == 0) ? headerFont : valueFont;
      if (i > 0 && i % 2 != 0) {
        row.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      } else {
        row.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
      }
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
      } else {
        row.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
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
