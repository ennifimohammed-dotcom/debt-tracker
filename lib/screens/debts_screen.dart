import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/debt_card.dart';
import 'add_edit_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtProvider>(builder: (_, p, __) {
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true, floating: true, expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(decoration: const BoxDecoration(gradient: C.headerGrad)),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('قائمة الديون',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${p.filtered.length} من ${p.all.length}',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11)),
                ],
              ),
              titlePadding: const EdgeInsets.only(right: 20, bottom: 12),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Container(
                color: const Color(0xFF0D47A1),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white),
                  onChanged: p.setSearch,
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم الشخص...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.6)),
                    suffixIcon: p.search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white),
                            onPressed: () => p.setSearch(''))
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, reverse: true,
                child: Row(children: [
                  _chip('الكل',       'all',                    p.statusF, p.setStatusF, Colors.blueGrey),
                  _chip('غير مدفوع', DebtStatus.unpaid.name,   p.statusF, p.setStatusF, C.unpaid),
                  _chip('جزئي',      DebtStatus.partial.name,  p.statusF, p.setStatusF, C.partial),
                  _chip('مدفوع',     DebtStatus.paid.name,     p.statusF, p.setStatusF, C.paid),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(width: 1, height: 22, color: Colors.grey.shade300)),
                  _chip('عليّ', DebtDirection.iOwe.name,    p.dirF, p.setDirF, C.unpaid),
                  _chip('لي',   DebtDirection.theyOwe.name, p.dirF, p.setDirF, C.paid),
                ]),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                DropdownButton<SortMode>(
                  value: p.sort, underline: const SizedBox(),
                  icon: const Icon(Icons.sort_rounded, size: 18),
                  style: const TextStyle(fontSize: 13, color: C.primary, fontFamily: 'Cairo'),
                  items: const [
                    DropdownMenuItem(value: SortMode.dateDesc,   child: Text('ترتيب: الأحدث')),
                    DropdownMenuItem(value: SortMode.amountDesc, child: Text('ترتيب: الأعلى مبلغاً')),
                    DropdownMenuItem(value: SortMode.name,       child: Text('ترتيب: الاسم')),
                  ],
                  onChanged: (v) => p.setSort(v!),
                ),
                Text('${p.filtered.length} نتيجة',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ]),
            ]),
          )),

          if (p.loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (p.filtered.isEmpty)
            SliverFillRemaining(child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('لا توجد نتائج', style: TextStyle(color: Colors.grey.shade500)),
              ]).animate().fadeIn(),
            ))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final d = p.filtered[i];
                  return DebtCard(
                    debt: d, index: i,
                    onEdit: () async {
                      final ok = await Navigator.push<bool>(context,
                          MaterialPageRoute(builder: (_) => AddEditScreen(debt: d)));
                      if (ok == true) p.load();
                    },
                    onDelete: () => p.remove(d.id!),
                  );
                },
                childCount: p.filtered.length,
              )),
            ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final ok = await Navigator.push<bool>(context,
                MaterialPageRoute(builder: (_) => const AddEditScreen()));
            if (ok == true) p.load();
          },
          child: const Icon(Icons.add_rounded),
        ).animate().scale(delay: const Duration(milliseconds: 300)),
      );
    });
  }
}

Widget _chip(String label, String val, String cur,
    ValueChanged<String> fn, Color color) {
  final active = cur == val;
  return GestureDetector(
    onTap: () => fn(val),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(
        color: active ? Colors.white : Colors.grey.shade600,
        fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal,
      )),
    ),
  );
}
