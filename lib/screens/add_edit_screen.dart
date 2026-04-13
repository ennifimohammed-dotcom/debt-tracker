import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../utils/app_theme.dart';

class AddEditScreen extends StatefulWidget {
  final Debt? debt;
  const AddEditScreen({super.key, this.debt});
  @override
  State<AddEditScreen> createState() => _State();
}

class _State extends State<AddEditScreen> {
  final _form       = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _paidCtrl   = TextEditingController();
  final _notesCtrl  = TextEditingController();
  DateTime      _date   = DateTime.now();
  DebtDirection _dir    = DebtDirection.iOwe;
  bool          _saving = false;

  bool get _isEdit => widget.debt != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.debt!;
      _nameCtrl.text   = d.personName;
      _amountCtrl.text = d.amount.toStringAsFixed(2);
      if (d.paidAmount > 0) _paidCtrl.text = d.paidAmount.toStringAsFixed(2);
      _notesCtrl.text  = d.notes ?? '';
      _date            = d.date;
      _dir             = d.direction;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _amountCtrl.dispose();
    _paidCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final debt = Debt(
      id:         widget.debt?.id,
      personName: _nameCtrl.text.trim(),
      amount:     double.parse(_amountCtrl.text),
      paidAmount: double.tryParse(_paidCtrl.text) ?? 0,
      date:       _date,
      notes:      _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      direction:  _dir,
    );
    final p = context.read<DebtProvider>();
    try {
      if (_isEdit) await p.edit(debt);
      else         await p.add(debt);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: C.unpaid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 120,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(decoration: const BoxDecoration(gradient: C.headerGrad)),
            title: Text(_isEdit ? 'تعديل الدين' : 'دين جديد',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            titlePadding: const EdgeInsets.only(right: 60, bottom: 16),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(key: _form, child: Column(children: [

            // Direction toggle
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0,3))]),
              child: Row(children: [
                _DBtn('دين عليّ', DebtDirection.iOwe,    _dir==DebtDirection.iOwe,    C.unpaidGrad, () => setState(() => _dir=DebtDirection.iOwe)),
                _DBtn('دين لي',  DebtDirection.theyOwe, _dir==DebtDirection.theyOwe, C.paidGrad,   () => setState(() => _dir=DebtDirection.theyOwe)),
              ]),
            ).animate().fadeIn().slideY(begin: -0.3, duration: 400.ms),
            const SizedBox(height: 20),

            _F(ctrl: _nameCtrl, label: 'اسم الشخص', icon: Icons.person_rounded,
              hint: 'أدخل الاسم الكامل', i: 1,
              val: (v) => v==null||v.trim().isEmpty ? 'الاسم مطلوب' : null),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: _F(ctrl: _paidCtrl,   label: 'المبلغ المدفوع', icon: Icons.payments_rounded,     hint: '0.00 درهم', isNum: true, i: 3)),
              const SizedBox(width: 12),
              Expanded(child: _F(ctrl: _amountCtrl, label: 'المبلغ الكلي',   icon: Icons.attach_money_rounded, hint: '0.00 درهم', isNum: true, i: 2,
                val: (v) { if(v==null||v.isEmpty) return 'مطلوب'; if(double.tryParse(v)==null) return 'رقم غير صالح'; return null; })),
            ]),
            const SizedBox(height: 14),

            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date,
                  firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null) setState(() => _date = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    const Icon(Icons.calendar_month_rounded, color: C.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(DateFormat('dd / MM / yyyy').format(_date),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ]),
                  Text('التاريخ', style: TextStyle(color: Colors.grey.shade500)),
                ]),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 14),

            _F(ctrl: _notesCtrl, label: 'ملاحظات (اختياري)', icon: Icons.notes_rounded,
              hint: 'أضف ملاحظة...', maxLines: 3, i: 4),
            const SizedBox(height: 32),

            SizedBox(width: double.infinity, height: 58,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: C.headerGrad, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: C.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0,6))]),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.save_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(_isEdit ? 'تحديث الدين' : 'حفظ الدين',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            const SizedBox(height: 40),
          ])),
        )),
      ]),
    );
  }
}

class _DBtn extends StatelessWidget {
  final String label; final DebtDirection dir;
  final bool active; final LinearGradient gradient; final VoidCallback onTap;
  const _DBtn(this.label, this.dir, this.active, this.gradient, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(gradient: active ? gradient : null, borderRadius: BorderRadius.circular(18)),
      child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
    )));
}

class _F extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint; final IconData icon;
  final bool isNum; final int maxLines, i;
  final String? Function(String?)? val;
  const _F({required this.ctrl, required this.label, required this.icon,
      required this.hint, this.isNum=false, this.maxLines=1, required this.i, this.val});
  @override
  Widget build(BuildContext context) => Animate(
    effects: [FadeEffect(delay: Duration(milliseconds: i*80)), SlideEffect(begin: const Offset(0,0.2), delay: Duration(milliseconds: i*80), duration: 300.ms)],
    child: TextFormField(controller: ctrl,
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : null,
      maxLines: maxLines, textAlign: TextAlign.right, validator: val,
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: C.primary))),
  );
}
