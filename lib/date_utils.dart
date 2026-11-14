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

    // Deletion / Backspacing
    if (newText.length < oldText.length) {
      int cursorPosition = newValue.selection.end;

      // If user deleted a hyphen (e.g. at position 3 "12-" or position 6 "12-05-")
      if ((oldText.length == 3 && oldText.endsWith('-') && newText.length == 2) ||
          (oldText.length == 6 && oldText.endsWith('-') && newText.length == 5)) {
        String digits = newText.replaceAll(RegExp(r'\D'), '');
        if (digits.isNotEmpty) {
          digits = digits.substring(0, digits.length - 1);
        }
        final formatted = _formatDigits(digits);
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      String digits = newText.replaceAll(RegExp(r'\D'), '');
      if (digits.length > 8) {
        digits = digits.substring(0, 8);
      }
      final formatted = _formatDigits(digits);
      int newSelection = cursorPosition.clamp(0, formatted.length);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newSelection),
      );
    }

    // Typing / Addition
    String digits = newText.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    final formatted = _formatDigits(digits);

    int selectionIndex = newValue.selection.end;
    if (digits.length == 2 && formatted.length == 3 && formatted.endsWith('-')) {
      selectionIndex = 3;
    } else if (digits.length == 4 && formatted.length == 6 && formatted.endsWith('-')) {
      selectionIndex = 6;
    } else {
      selectionIndex = selectionIndex.clamp(0, formatted.length);
      if (selectionIndex < formatted.length &&
          formatted[selectionIndex - 1] == '-' &&
          oldText.length < newText.length) {
        selectionIndex = (selectionIndex + 1).clamp(0, formatted.length);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  static String _formatDigits(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 2) return digits;
    if (digits.length <= 4) {
      return '${digits.substring(0, 2)}-${digits.substring(2)}';
    }
    return '${digits.substring(0, 2)}-${digits.substring(2, 4)}-${digits.substring(4)}';
  }
}

bool isValidDateDDMMYYYY(String dateStr) {
  final trimmed = dateStr.trim();
  if (trimmed.isEmpty) return true; // Empty string is acceptable for optional fields

  final parts = trimmed.split('-');
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

String formatToDDMMYYYY(String dateStr) {
  final trimmed = dateStr.trim();
  if (trimmed.isEmpty) return '';

  final regex = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})$');
  final match = regex.firstMatch(trimmed);
  if (match != null) {
    final day = match.group(1)!.padLeft(2, '0');
    final month = match.group(2)!.padLeft(2, '0');
    final year = match.group(3)!;
    return '$day-$month-$year';
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
      final parts = currentText.split('-');
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
    final formatted = DateFormat('dd-MM-yyyy').format(picked);
    controller.text = formatted;
    if (onChanged != null) {
      onChanged(formatted);
    }
  }
}
