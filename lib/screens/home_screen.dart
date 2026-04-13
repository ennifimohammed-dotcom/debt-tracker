import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/debt_card.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNav;
  const HomeScreen({super.key, required this.onNav});

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
      final recent = p.all.take(5).toList();

      return Scaffold(
        body: RefreshIndicator(
          onRefresh: p.load,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 255, pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: C.headerGrad),
                  child: SafeArea(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.account_balance_rounded,
                              color: Colors.white, size: 24),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Text('Debt Tracker Pro',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
                            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                        ]),
                      ]),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(theyL >= iOweL
                                ? '+${MAD.fmt(theyL - iOweL)}'
                                : '-${MAD.fmt(iOweL - theyL)}',
                              style: TextStyle(
                                color: theyL >= iOweL ? C.gold : Colors.red.shade200,
                                fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(theyL >= iOweL ? 'الرصيد لصالحك' : 'الرصيد عليك',
                              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            const Text('الرصيد الصافي',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${p.all.length} دين مسجل',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _Mini(label: 'متبقي لي',   value: MAD.fmtShort(theyL), icon: Icons.arrow_downward_rounded, color: C.paid)),
                        const SizedBox(width: 10),
                        Expanded(child: _Mini(label: 'متبقي عليّ', value: MAD.fmtShort(iOweL), icon: Icons.arrow_upward_rounded,   color: C.unpaid)),
                      ]),
                    ]),
                  )),
                ),
                title: const Text('الرئيسية',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                titlePadding: const EdgeInsets.only(right: 20, bottom: 16),
              ),
            ),

            if (p.loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  Row(children: [
                    Expanded(child: _ProgressCard(title: 'ديون عليّ', gradient: C.unpaidGrad,
                        total: iOweT, paid: iOweP, index: 0)),
                    const SizedBox(width: 12),
                    Expanded(child: _ProgressCard(title: 'ديون لي', gradient: C.paidGrad,
                        total: theyT, paid: theyP, index: 1)),
                  ]),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    TextButton(onPressed: () => onNav(1), child: const Text('عرض الكل')),
                    const Text('آخر الديون',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: C.primary)),
                  ]),
                  const SizedBox(height: 8),
                  if (recent.isEmpty)
                    _Empty(onAdd: () => _add(context, p))
                  else
                    ...recent.asMap().entries.map((e) => DebtCard(
                      debt: e.value, index: e.key,
                      onEdit:   () => _edit(context, p, e.value),
                      onDelete: () => p.remove(e.value.id!),
                    )),
                  const SizedBox(height: 80),
                ])),
              ),
          ]),
        ),
        floatingActionButton: _FAB(onTap: () => _add(context, p)),
      );
    });
  }

  Future<void> _add(BuildContext ctx, DebtProvider p) async {
    final ok = await Navigator.push<bool>(ctx, MaterialPageRoute(builder: (_) => const AddEditScreen()));
    if (ok == true) p.load();
  }
  Future<void> _edit(BuildContext ctx, DebtProvider p, Debt d) async {
    final ok = await Navigator.push<bool>(ctx, MaterialPageRoute(builder: (_) => AddEditScreen(debt: d)));
    if (ok == true) p.load();
  }
}

class _Mini extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Mini({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 14)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10)),
        Text(value,  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ])),
    ]),
  );
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final double total, paid;
  final LinearGradient gradient;
  final int index;
  const _ProgressCard({required this.title, required this.total, required this.paid, required this.gradient, required this.index});
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
    return Animate(
      effects: [FadeEffect(delay: Duration(milliseconds: index*150)), ScaleEffect(begin: const Offset(0.88,0.88), delay: Duration(milliseconds: index*150))],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0,6))]),
        child: Column(children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Stack(alignment: Alignment.center, children: [
            SizedBox(width: 84, height: 84,
              child: CircularProgressIndicator(value: pct, strokeWidth: 9,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.white))),
            Text('${(pct*100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          Text('${MAD.fmtShort(paid)}\n/ ${MAD.fmtShort(total)}',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _FAB extends StatefulWidget {
  final VoidCallback onTap;
  const _FAB({required this.onTap});
  @override State<_FAB> createState() => _FABState();
}
class _FABState extends State<_FAB> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  late final Animation<double> _s = Tween(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s,
      child: Container(width: 64, height: 64,
        decoration: BoxDecoration(gradient: C.headerGrad, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: C.primary.withOpacity(0.45), blurRadius: 18, offset: const Offset(0,7))]),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
      )),
  ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut);
}

class _Empty extends StatelessWidget {
  final VoidCallback onAdd;
  const _Empty({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('لا توجد ديون بعد', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: onAdd,
          icon: const Icon(Icons.add_rounded), label: const Text('أضف أول دين')),
      ]).animate().fadeIn()),
  );
}
