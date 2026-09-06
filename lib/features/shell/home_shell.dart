import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audit/presentation/audit_screen.dart';
import '../auth/providers/auth_providers.dart';
import '../events/presentation/execution_calendar_screen.dart';
import '../habits/presentation/habit_screen.dart';
import '../tasks/presentation/brain_dump_screen.dart';
import '../wishlist/presentation/wishlist_screen.dart';

/// Material 3 shell: 5 tabs evenly spaced in NavigationBar.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Brain Dump',
    'Execution',
    'Wish List',
    'Audit',
    'Habits',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: 48,
        title: Text(
          _titles[_index],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            color: Colors.white70,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Lock',
            icon: const Icon(Icons.lock_outline, size: 20),
            onPressed: () => ref.read(authSessionProvider.notifier).lock(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          BrainDumpScreen(),
          ExecutionCalendarScreen(),
          WishlistScreen(),
          AuditScreen(),
          HabitScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        // Even spacing across full width for 5 destinations.
        indicatorColor: const Color(0xFFB39DDB).withValues(alpha: 0.28),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Brain Dump',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Execution',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Wish List',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Audit',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat),
            selectedIcon: Icon(Icons.repeat_on),
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}
