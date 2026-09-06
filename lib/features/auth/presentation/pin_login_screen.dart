import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

/// Touch-first 3-character PIN unlock screen (letters or digits).
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authSessionProvider.notifier).unlockWithPin(_controller.text);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter PIN',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                '3 letters or digits',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLength: 3,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  letterSpacing: 16,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB39DDB)),
                  ),
                ),
                onChanged: (v) {
                  if (v.length == 3) _submit();
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              if (_loading) const CircularProgressIndicator(color: Color(0xFFB39DDB)),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Color(0xFFEF9A9A))),
            ],
          ),
        ),
      ),
    );
  }
}
