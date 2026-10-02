import 'package:flutter/material.dart';

import '../../audit/domain/audit_energy.dart';

/// Result of a Brain Dump edit (title + $ + energy). Wishlist still pops a String.
class BrainDumpEditResult {
  const BrainDumpEditResult({
    required this.title,
    required this.value,
    required this.energy,
  });

  final String title;
  final int value;
  final AuditEnergy energy;
}

/// Dark sheet to rename text (keyboard autofocus). Shared by tasks & wishlist.
class EditTaskSheet extends StatefulWidget {
  const EditTaskSheet({
    super.key,
    required this.initialTitle,
    this.heading = 'Edit task',
    this.fieldLabel = 'Task',
    /// When true, show Audit-style $1–$4 and 3 energy chips (Brain Dump only).
    this.showLeverageAndEnergy = false,
    this.initialValue = 1,
    this.initialEnergy = AuditEnergy.neutral,
  });

  final String initialTitle;
  final String heading;
  final String fieldLabel;
  final bool showLeverageAndEnergy;
  final int initialValue;
  final AuditEnergy initialEnergy;

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late final _controller = TextEditingController(text: widget.initialTitle);
  late int _value = widget.initialValue;
  late AuditEnergy _energy = widget.initialEnergy;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.showLeverageAndEnergy) {
      Navigator.of(context).pop(
        BrainDumpEditResult(title: text, value: _value, energy: _energy),
      );
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.heading,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true, // keyboard opens immediately on mobile
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: widget.fieldLabel,
              labelStyle: const TextStyle(color: Colors.white54),
            ),
          ),
          if (widget.showLeverageAndEnergy) ...[
            const SizedBox(height: 16),
            const Text('Leverage', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            // Same $1–$4 chips as Audit.
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4].map((v) {
                return ChoiceChip(
                  label: Text('\$$v'),
                  selected: _value == v,
                  onSelected: (_) => setState(() => _value = v),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Energy', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AuditEnergy.values.map((e) {
                return ChoiceChip(
                  label: Text(e.label),
                  selected: _energy == e,
                  selectedColor: e.color.withValues(alpha: 0.35),
                  onSelected: (_) => setState(() => _energy = e),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
