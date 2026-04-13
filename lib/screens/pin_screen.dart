import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pin_service.dart';
import '../utils/app_theme.dart';
import 'shell_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onSuccess;
  const PinScreen({super.key, this.isSetup = false, this.onSuccess});
  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _error = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: 400.ms);
    _shake = Tween(begin: 0.0, end: 1.0).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _addDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _error = false;
      _pin += d;
    });
    if (_pin.length == 4) _checkPin();
  }

  void _removeDigit() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _checkPin() async {
    await Future.delayed(200.ms);
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() { _confirmPin = _pin; _pin = ''; _isConfirming = true; });
      } else {
        if (_pin == _confirmPin) {
          await PinService.setPin(_pin);
          if (mounted) {
            widget.onSuccess?.call();
            if (Navigator.canPop(context)) Navigator.pop(context, true);
          }
        } else {
          _shakeCtrl.forward(from: 0);
          setState(() { _error = true; _pin = ''; _isConfirming = false; _confirmPin = ''; });
        }
      }
    } else {
      final ok = await PinService.verify(_pin);
      if (ok) {
        if (mounted) {
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ShellScreen()));
          }
        }
      } else {
        _shakeCtrl.forward(from: 0);
        setState(() { _error = true; _pin = ''; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: C.headerGrad),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.lock_rounded, size: 56, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                widget.isSetup
                    ? (_isConfirming ? 'أعد إدخال الرقم السري' : 'أنشئ رقماً سرياً')
                    : 'أدخل الرقم السري',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_error)
                Text('رقم خاطئ، حاول مجدداً',
                  style: TextStyle(color: Colors.red.shade200, fontSize: 14),
                ).animate().shakeX(),
              const SizedBox(height: 40),
              // PIN dots
              AnimatedBuilder(
                animation: _shake,
                builder: (_, __) => Transform.translate(
                  offset: Offset(_shake.value * 10 * ((_shake.value * 10).round() % 2 == 0 ? 1 : -1), 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                      ),
                    )),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Keypad
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...'123456789'.split('').map((d) => _KeyBtn(d, () => _addDigit(d))),
                      const SizedBox(),
                      _KeyBtn('0', () => _addDigit('0')),
                      _KeyBtn('⌫', _removeDigit, isDelete: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;
  const _KeyBtn(this.label, this.onTap, {this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDelete ? 0.1 : 0.2),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDelete ? 22 : 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
