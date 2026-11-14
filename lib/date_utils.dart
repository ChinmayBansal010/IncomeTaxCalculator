import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Handle Deletion / Backspace
    if (newText.length < oldText.length) {
      int cursorPosition = newValue.selection.end;

      // If user deleted a '/' (e.g. at position 3 "01/" or position 6 "01/03/")
      if ((oldText.length == 3 && oldText.endsWith('/') && !newText.contains('/')) ||
          (oldText.length == 6 && oldText.endsWith('/') && newText.endsWith('/'))) {
        String digits = newText.replaceAll(RegExp(r'\D'), '');
        if (digits.isNotEmpty) {
          digits = digits.substring(0, digits.length - 1);
        }
        final formatted = _formatDigitsOnly(digits);
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      final formatted = _formatDateInput(newText);
      final newSelection = cursorPosition.clamp(0, formatted.length);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newSelection),
      );
    }

    // Handle Typing
    final formatted = _formatDateInput(newText);

    // Calculate cursor position
    int selectionIndex = newValue.selection.end;

    if (formatted.length == 3 && !oldText.startsWith(formatted) && formatted.endsWith('/')) {
      selectionIndex = 3;
    } else if (formatted.length == 6 && !oldText.startsWith(formatted) && formatted.endsWith('/')) {
      selectionIndex = 6;
    } else {
      selectionIndex = selectionIndex.clamp(0, formatted.length);
      if (selectionIndex < formatted.length &&
          formatted[selectionIndex - 1] == '/' &&
          oldText.length < newText.length) {
        selectionIndex = (selectionIndex + 1).clamp(0, formatted.length);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  static String _formatDateInput(String text) {
    String clean = text.replaceAll(RegExp(r'[^0-9/.-]'), '');
    if (clean.isEmpty) return '';

    clean = clean.replaceAll('-', '/').replaceAll('.', '/');

    List<String> parts = clean.split('/');

    String dayDigits = parts[0].replaceAll(RegExp(r'\D'), '');
    String monthDigits = parts.length > 1 ? parts[1].replaceAll(RegExp(r'\D'), '') : '';
    String yearDigits = parts.length > 2 ? parts[2].replaceAll(RegExp(r'\D'), '') : '';

    // Day processing
    if (parts.length > 1 && dayDigits.length == 1) {
      dayDigits = '0$dayDigits';
    } else if (dayDigits.length == 1) {
      final d = int.tryParse(dayDigits) ?? 0;
      if (d >= 4) { // 4..9 cannot start a 2-digit day <= 31
        dayDigits = '0$dayDigits';
      }
    } else if (dayDigits.length > 2) {
      final val2 = int.tryParse(dayDigits.substring(0, 2)) ?? 0;
      if (val2 > 31) {
        monthDigits = dayDigits.substring(1) + monthDigits;
        dayDigits = '0${dayDigits[0]}';
      } else {
        monthDigits = dayDigits.substring(2) + monthDigits;
        dayDigits = dayDigits.substring(0, 2);
      }
    } else if (dayDigits.length == 2) {
      final val = int.tryParse(dayDigits) ?? 0;
      if (val > 31) {
        monthDigits = dayDigits[1] + monthDigits;
        dayDigits = '0${dayDigits[0]}';
      }
    }

    // Month processing
    if (parts.length > 2 && monthDigits.length == 1) {
      monthDigits = '0$monthDigits';
    } else if (monthDigits.length == 1) {
      final m = int.tryParse(monthDigits) ?? 0;
      if (m >= 2) { // 2..9 cannot start a 2-digit month <= 12
        monthDigits = '0$monthDigits';
      }
    } else if (monthDigits.length > 2) {
      final val2 = int.tryParse(monthDigits.substring(0, 2)) ?? 0;
      if (val2 > 12) {
        yearDigits = monthDigits.substring(1) + yearDigits;
        monthDigits = '0${monthDigits[0]}';
      } else {
        yearDigits = monthDigits.substring(2) + monthDigits;
        monthDigits = monthDigits.substring(0, 2);
      }
    } else if (monthDigits.length == 2) {
      final val = int.tryParse(monthDigits) ?? 0;
      if (val > 12) {
        yearDigits = monthDigits[1] + yearDigits;
        monthDigits = '0${monthDigits[0]}';
      }
    }

    // Year processing
    if (yearDigits.length > 4) {
      yearDigits = yearDigits.substring(0, 4);
    }

    // Assemble formatted DD/MM/YYYY string
    StringBuffer sb = StringBuffer();
    sb.write(dayDigits);

    if (dayDigits.length == 2) {
      sb.write('/');
      if (monthDigits.isNotEmpty) {
        sb.write(monthDigits);
        if (monthDigits.length == 2) {
          sb.write('/');
          if (yearDigits.isNotEmpty) {
            sb.write(yearDigits);
          }
        }
      }
    }

    return sb.toString();
  }

  static String _formatDigitsOnly(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 2) return digits;
    if (digits.length <= 4) {
      return '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return '${digits.substring(0, 2)}/${digits.substring(2, 4)}/${digits.substring(4)}';
  }
}

bool isValidDateDDMMYYYY(String dateStr) {
  final trimmed = dateStr.trim();
  if (trimmed.isEmpty) return true; // Optional empty date

  final parts = trimmed.contains('/') ? trimmed.split('/') : trimmed.split('-');
  if (parts.length != 3) return false;

  final dayStr = parts[0];
  final monthStr = parts[1];
  final yearStr = parts[2];

  if (dayStr.length != 2 || monthStr.length != 2 || yearStr.length != 4) {
    return false;
  }

  final day = int.tryParse(dayStr);
  final month = int.tryParse(monthStr);
  final year = int.tryParse(yearStr);

  if (day == null || month == null || year == null) return false;
  if (year < 1900 || year > 2100) return false;
  if (month < 1 || month > 12) return false;

  int maxDays = 31;
  if (month == 4 || month == 6 || month == 9 || month == 11) {
    maxDays = 30;
  } else if (month == 2) {
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    maxDays = isLeapYear ? 29 : 28;
  }

  return day >= 1 && day <= maxDays;
}

DateTime? parseDateDDMMYYYY(String dateStr) {
  final trimmed = dateStr.trim();
  if (trimmed.isEmpty) return null;

  final clean = trimmed.replaceAll('-', '/').replaceAll('.', '/');
  final parts = clean.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return null;
  if (year < 1900 || year > 2100 || month < 1 || month > 12) return null;

  int maxDays = 31;
  if (month == 4 || month == 6 || month == 9 || month == 11) {
    maxDays = 30;
  } else if (month == 2) {
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    maxDays = isLeapYear ? 29 : 28;
  }

  if (day < 1 || day > maxDays) return null;

  return DateTime(year, month, day);
}

String formatToDDMMYYYY(String dateStr) {
  final trimmed = dateStr.trim();
  if (trimmed.isEmpty) return '';

  final regex = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})$');
  final match = regex.firstMatch(trimmed);
  if (match != null) {
    final day = match.group(1)!.padLeft(2, '0');
    final month = match.group(2)!.padLeft(2, '0');
    final year = match.group(3)!;
    return '$day/$month/$year';
  }
  return trimmed;
}

Future<void> selectDateDDMMYYYY(
  BuildContext context,
  TextEditingController controller, {
  ValueChanged<String>? onChanged,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  DateTime initialDate = DateTime.now();
  final currentText = controller.text.trim();
  if (isValidDateDDMMYYYY(currentText) && currentText.length == 10) {
    try {
      final parts = currentText.contains('/') ? currentText.split('/') : currentText.split('-');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);
      initialDate = DateTime(y, m, d);
    } catch (_) {}
  }

  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate ?? DateTime(1900),
    lastDate: lastDate ?? DateTime(2100),
  );

  if (picked != null) {
    final formatted = DateFormat('dd/MM/yyyy').format(picked);
    controller.text = formatted;
    if (onChanged != null) {
      onChanged(formatted);
    }
  }
}
