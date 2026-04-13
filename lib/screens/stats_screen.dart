import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../services/export_service.dart';
import '../utils/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  int  _touched   = -1;
  bool _exporting = false;

  Future<void> _export(List<Debt> debts) async {
    if (debts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد بيانات للتصدير'),
              backgroundColor: C.unpaid));
      return;
    }
    setState(() => _exporting = true);
    try {
      final path = await ExportService.toXlsx(debts);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم الحفظ:\n$path'),
        backgroundColor: C.paid,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: C.unpaid));
    } finally {
      setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtProvider>(builder: (_, p, __) {
      final s      = p.summary;
      final iOweL  = s['iOweLeft']  ?? 0;
      final theyL  = s['theyLeft']  ?? 0;
      final iOweT  = s['iOweTotal'] ?? 0;
      final iOweP  = s['iOwePaid']  ?? 0;
      final theyT  = s['theyTotal'] ?? 0;
      final theyP  = s['theyPaid']  ?? 0;

      final unpaid  = p.all.where((d) => d.status == DebtStatus.unpaid).length;
      final partial = p.all.where((d) => d.status == DebtStatus.partial).length;
      final paid    = p.all.where((d) => d.status == DebtStatus.paid).length;
      final total   = p.all.length;

      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true, expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(decoration: const BoxDecoration(gradient: C.headerGrad)),
              title: const Text('الإحصائيات',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              titlePadding: const EdgeInsets.only(right: 20, bottom: 16),
            ),
          ),

          if (p.loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // Export button
                SizedBox(width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _exporting ? null : () => _export(p.all),
                    icon: _exporting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.table_chart_rounded),
                    label: Text(_exporting ? 'جاري التصدير...' : 'تصدير إلى Excel (xlsx)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.paid,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 20),

                // Net balance
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: C.headerGrad,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: C.primary.withOpacity(0.3),
                        blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        theyL >= iOweL
                            ? '+${MAD.fmt(theyL - iOweL)}'
                            : '-${MAD.fmt(iOweL - theyL)}',
                        style: TextStyle(
                          color: theyL >= iOweL ? C.gold : Colors.red.shade200,
                          fontSize: 22, fontWeight: FontWeight.bold,
                        )),
                      Text(theyL >= iOweL ? 'الرصيد لصالحك' : 'الرصيد عليك',
                          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('الرصيد الصافي',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('$total دين مسجل',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                    ]),
                  ]),
                ).animate().fadeIn(),
                const SizedBox(height: 20),

                // Pie chart
                if (total > 0) ...[
                  _sTitle('توزيع الديون حسب الحالة'),
                  const SizedBox(height: 12),
                  Container(
                    height: 230, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                          blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [
                      Expanded(child: PieChart(PieChartData(
                        pieTouchData: PieTouchData(touchCallback: (_, resp) {
                          setState(() =>
                              _touched = resp?.touchedSection?.touchedSectionIndex ?? -1);
                        }),
                        sections: [
                          if (unpaid  > 0) _sec(0, unpaid.toDouble(),  C.unpaid,  'غير مدفوع'),
                          if (partial > 0) _sec(1, partial.toDouble(), C.partial, 'جزئي'),
                          if (paid    > 0) _sec(2, paid.toDouble(),    C.paid,    'مدفوع'),
                        ],
                        centerSpaceRadius: 40,
                      ))),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _leg('غير مدفوع', C.unpaid,  '$unpaid'),
                          const SizedBox(height: 10),
                          _leg('مدفوع جزئي', C.partial, '$partial'),
                          const SizedBox(height: 10),
                          _leg('مدفوع',      C.paid,    '$paid'),
                          const Divider(height: 16),
                          _leg('المجموع',    C.primary, '$total'),
                        ],
                      ),
                    ]),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200))
                   .scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 20),
                ],

                // Financial cards
                _sTitle('الملخص المالي'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _StatCard(title: 'ديون عليّ', gradient: C.unpaidGrad,
                      total: iOweT, paid: iOweP, remaining: iOweL, index: 0)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'ديون لي', gradient: C.paidGrad,
                      total: theyT, paid: theyP, remaining: theyL, index: 1)),
                ]),
                const SizedBox(height: 80),
              ])),
            ),
        ]),
      );
    });
  }

  PieChartSectionData _sec(int i, double v, Color c, String title) =>
      PieChartSectionData(
        value: v, color: c,
        title: _touched == i ? '$title\n${v.toInt()}' : v.toInt().toString(),
        radius: _touched == i ? 72 : 58,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
}

Widget _sTitle(String t) => Padding(
  padding: const EdgeInsets.only(right: 4),
  child: Text(t, textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: C.primary)),
);

Widget _leg(String label, Color c, String val) => Row(mainAxisSize: MainAxisSize.min, children: [
  Text(val, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 14)),
  const SizedBox(width: 6),
  Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
  const SizedBox(width: 6),
  Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
]);

class _StatCard extends StatelessWidget {
  final String title;
  final double total, paid, remaining;
  final LinearGradient gradient;
  final int index;
  const _StatCard({required this.title, required this.total, required this.paid,
      required this.remaining, required this.gradient, required this.index});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: 300 + index * 150)),
        SlideEffect(begin: const Offset(0, 0.2),
            delay: Duration(milliseconds: 300 + index * 150)),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _r('الكلي',   MAD.fmt(total)),
          const SizedBox(height: 4),
          _r('المدفوع', MAD.fmt(paid)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct, minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(MAD.fmt(remaining),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}

Widget _r(String l, String v) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 12)),
    Text(l, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12)),
  ],
);
double totalYouOwe = debts
  .where((d) => d.type == 'debit')
  .fold(0, (sum, d) => sum + d.amount);

double totalYouGet = debts
  .where((d) => d.type == 'credit')
  .fold(0, (sum, d) => sum + d.amount);
