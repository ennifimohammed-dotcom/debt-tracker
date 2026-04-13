import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pin_service.dart';
import '../utils/app_theme.dart';
import 'pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pinEnabled = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final e = await PinService.isEnabled();
    setState(() => _pinEnabled = e);
  }

  Future<void> _togglePin(bool val) async {
    if (val) {
      final result = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const PinScreen(isSetup: true)));
      if (result == true) setState(() => _pinEnabled = true);
    } else {
      // Verify before disabling
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تعطيل الرقم السري', textAlign: TextAlign.right),
          content: const Text('هل تريد تعطيل الحماية بالرقم السري؟', textAlign: TextAlign.right),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: C.unpaid),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تعطيل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (ok == true) {
        await PinService.disablePin();
        setState(() => _pinEnabled = false);
      }
    }
  }

  Future<void> _changePin() async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const PinScreen(isSetup: true)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(decoration: BoxDecoration(gradient: C.headerGrad)),
              title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              titlePadding: const EdgeInsets.only(right: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Security section
              _SectionHeader('الأمان والحماية').animate().fadeIn(),
              const SizedBox(height: 8),
              _SettingCard(children: [
                _SettingTile(
                  icon: Icons.lock_rounded,
                  iconColor: C.primary,
                  title: 'الرقم السري',
                  subtitle: _pinEnabled ? 'مفعّل — التطبيق محمي' : 'معطّل — التطبيق مفتوح',
                  trailing: Switch(
                    value: _pinEnabled,
                    activeColor: C.primary,
                    onChanged: _togglePin,
                  ),
                ),
                if (_pinEnabled) ...[
                  const Divider(height: 1),
                  _SettingTile(
                    icon: Icons.edit_rounded,
                    iconColor: C.partial,
                    title: 'تغيير الرقم السري',
                    subtitle: 'أنشئ رقماً سرياً جديداً',
                    trailing: const Icon(Icons.chevron_left_rounded, color: Colors.grey),
                    onTap: _changePin,
                  ),
                ],
              ]).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),

              // App info
              _SectionHeader('عن التطبيق').animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              _SettingCard(children: [
                _SettingTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: C.primary,
                  title: 'الإصدار',
                  subtitle: '2.0.0',
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: C.paid,
                  title: 'التطبيق',
                  subtitle: 'ديون — إدارة ديونك بذكاء',
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.android_rounded,
                  iconColor: Colors.green,
                  title: 'المتطلبات',
                  subtitle: 'Android 13 أو أحدث',
                ),
              ]).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 80),
            ])),
          ),
        ],
      ),
    );
  }
}

Widget _SectionHeader(String title) => Padding(
  padding: const EdgeInsets.only(right: 4, bottom: 2),
  child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: C.primary, letterSpacing: 0.5)),
);

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(children: children),
  );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingTile({required this.icon, required this.iconColor, required this.title, required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), textAlign: TextAlign.right),
    subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), textAlign: TextAlign.right),
    trailing: trailing,
  );
}
