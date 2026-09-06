import 'package:flutter/material.dart';

import '../domain/audit_energy.dart';
import '../domain/audit_item.dart';

/// Bottom sheet to add or edit an Audit item (name + $ + energy).
class AuditEditSheet extends StatefulWidget {
  const AuditEditSheet({super.key, this.initial});

  /// null = create mode; non-null = edit mode.
  final AuditItem? initial;

  @override
  State<AuditEditSheet> createState() => _AuditEditSheetState();
}

class _AuditEditSheetState extends State<AuditEditSheet> {
  late final _name = TextEditingController(text: widget.initial?.taskName ?? '');
  late int _value = widget.initial?.value ?? 1;
  late AuditEnergy _energy = widget.initial?.energy ?? AuditEnergy.neutral;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final text = _name.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(
      AuditItem(
        id: widget.initial?.id ?? '',
        taskName: text,
        energy: _energy,
        value: _value,
      ),
    );
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
            widget.initial == null ? 'Add audit item' : 'Edit audit item',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(
              labelText: 'Task name',
              labelStyle: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Leverage', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          // $1–$4 selector
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
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
