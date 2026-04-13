import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../utils/app_theme.dart';

class ExportService {
  static Future<String> toXlsx(List<Debt> debts) async {
    final ex    = Excel.createExcel();
    final sheet = ex['ديون'];
    ex.delete('Sheet1');

    final hStyle = CellStyle(
      bold: true, horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1A237E'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final headers = ['#','الاسم','التاريخ','النوع',
      'المبلغ الكلي (درهم)','المدفوع (درهم)','المتبقي (درهم)',
      'التقدم %','ملاحظات','الحالة'];
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = hStyle;
    }
    sheet.setColumnWidth(0, 5);  sheet.setColumnWidth(1, 22);
    sheet.setColumnWidth(2, 14); sheet.setColumnWidth(3, 14);
    sheet.setColumnWidth(4, 20); sheet.setColumnWidth(5, 20);
    sheet.setColumnWidth(6, 20); sheet.setColumnWidth(7, 12);
    sheet.setColumnWidth(8, 26); sheet.setColumnWidth(9, 18);

    final dateFmt = DateFormat('dd/MM/yyyy');
    for (int i = 0; i < debts.length; i++) {
      final d = debts[i]; final row = i + 1;
      String bg;
      switch (d.status) {
        case DebtStatus.paid:    bg = '#C8E6C9'; break;
        case DebtStatus.partial: bg = '#FFF9C4'; break;
        case DebtStatus.unpaid:  bg = '#FFCDD2'; break;
      }
      final rs = CellStyle(backgroundColorHex: ExcelColor.fromHexString(bg),
          horizontalAlign: HorizontalAlign.Center);
      void s(int c, CellValue v) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
        cell.value = v; cell.cellStyle = rs;
      }
      s(0, IntCellValue(i+1));
      s(1, TextCellValue(d.personName));
      s(2, TextCellValue(dateFmt.format(d.date)));
      s(3, TextCellValue(d.direction.labelFull));
      s(4, TextCellValue(MAD.num(d.amount)));
      s(5, TextCellValue(MAD.num(d.paidAmount)));
      s(6, TextCellValue(MAD.num(d.remaining)));
      s(7, TextCellValue('${d.progressPct.toStringAsFixed(0)}%'));
      s(8, TextCellValue(d.notes ?? ''));
      s(9, TextCellValue('${d.status.emoji} ${d.status.label}'));
    }

    final tr = debts.length + 1;
    final ts = CellStyle(bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#E3F2FD'),
        horizontalAlign: HorizontalAlign.Center);
    void t(int c, CellValue v) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: tr));
      cell.value = v; cell.cellStyle = ts;
    }
    t(0, TextCellValue('')); t(1, TextCellValue('المجموع'));
    t(2, TextCellValue('')); t(3, TextCellValue(''));
    t(4, TextCellValue(MAD.num(debts.fold(0.0,(s,d)=>s+d.amount))));
    t(5, TextCellValue(MAD.num(debts.fold(0.0,(s,d)=>s+d.paidAmount))));
    t(6, TextCellValue(MAD.num(debts.fold(0.0,(s,d)=>s+d.remaining))));
    t(7, TextCellValue('')); t(8, TextCellValue(''));
    t(9, TextCellValue('${debts.length} دين'));

    const dl = '/storage/emulated/0/Download';
    await Directory(dl).create(recursive: true);
    final path  = '$dl/ديون_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final bytes = ex.save();
    if (bytes == null) throw Exception('فشل توليد الملف');
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
