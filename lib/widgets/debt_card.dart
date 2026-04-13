import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../utils/app_theme.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final int index;
  final VoidCallback onEdit, onDelete;
  const DebtCard({super.key, required this.debt, required this.index,
      required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final sc = debt.status.color;
    LinearGradient grad;
    switch (debt.status) {
      case DebtStatus.paid:    grad = C.paidGrad;    break;
      case DebtStatus.partial: grad = C.partialGrad; break;
      case DebtStatus.unpaid:  grad = C.unpaidGrad;  break;
    }

    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: index * 70)),
        SlideEffect(begin: const Offset(0.1, 0), delay: Duration(milliseconds: index * 70)),
      ],
      child: Dismissible(
        key: Key('dc_${debt.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('حذف الدين', textAlign: TextAlign.right),
            content: Text('حذف دين "${debt.personName}"؟', textAlign: TextAlign.right),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: C.unpaid),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        onDismissed: (_) => onDelete(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(color: C.unpaid, borderRadius: BorderRadius.circular(18)),
          alignment: Alignment.centerLeft,
          child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: IntrinsicHeight(child: Row(children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                gradient: grad,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
              ),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(MAD.fmt(debt.amount),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: C.primary)),
                    const SizedBox(height: 2),
                    Text(DateFormat('dd/MM/yyyy').format(debt.date),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  ]),
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(debt.personName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(debt.direction.label,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                              color: debt.status.bg, borderRadius: BorderRadius.circular(10)),
                          child: Text(debt.status.label,
                              style: TextStyle(color: sc, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ]),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 24, backgroundColor: sc.withOpacity(0.12),
                      child: Text(debt.personName[0],
                          style: TextStyle(color: sc, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Text(MAD.fmt(debt.remaining),
                      style: TextStyle(color: sc, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${debt.progressPct.toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: debt.progress, minHeight: 8,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(sc),
                  ),
                ),
                if (debt.notes != null && debt.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Flexible(child: Text(debt.notes!,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12,
                            fontStyle: FontStyle.italic),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 4),
                    Icon(Icons.notes_rounded, size: 13, color: Colors.grey.shade400),
                  ]),
                ],
              ]),
            )),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 42,
                decoration: BoxDecoration(
                  color: C.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                ),
                child: const Icon(Icons.edit_rounded, color: C.primary, size: 18),
              ),
            ),
          ])),
        ),
      ),
    );
  }
}
