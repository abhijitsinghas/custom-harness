import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';

/// Represents a single action in the FAB speed dial.
class _FabSpeedDialAction {
  const _FabSpeedDialAction({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;
}

/// FAB Speed Dial widget with expand/collapse animation.
/// US-0.4.4, US-0.4.5: Four mini-FABs (Voice Input, Scan Cover, Scan Barcode, Add Manually).
class FabSpeedDial extends StatefulWidget {
  const FabSpeedDial({super.key});

  @override
  State<FabSpeedDial> createState() => _FabSpeedDialState();
}

class _FabSpeedDialState extends State<FabSpeedDial>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!mounted) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _collapse() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _FabSpeedDialAction(
        icon: Icons.mic,
        label: 'Voice Input',
        semanticsLabel: 'Voice Input, button',
        onTap: () {
          _collapse();
          context.push(kRouteVoiceInput);
        },
      ),
      _FabSpeedDialAction(
        icon: Icons.camera_alt,
        label: 'Scan Cover',
        semanticsLabel: 'Scan Cover, button',
        onTap: () {
          _collapse();
          context.push(kRouteScannerOcr);
        },
      ),
      _FabSpeedDialAction(
        icon: Icons.qr_code_scanner,
        label: 'Scan Barcode',
        semanticsLabel: 'Scan Barcode, button',
        onTap: () {
          _collapse();
          context.push(kRouteScannerBarcode);
        },
      ),
      _FabSpeedDialAction(
        icon: Icons.edit,
        label: 'Add Manually',
        semanticsLabel: 'Add Manually, button',
        onTap: () {
          _collapse();
          context.push(kRouteBookAdd);
        },
      ),
    ];

    return Stack(
      children: [
        // Backdrop to close on tap outside
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _collapse,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        // FAB column
        Positioned(
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Mini FABs with staggered animation
              ...actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                final delay = index * 0.08;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final value = (_controller.value - delay).clamp(0.0, 1.0);
                    final opacity = Curves.easeOut.transform(value);
                    final offset = (1 - value) * 30;
                    return AnimatedOpacity(
                      opacity: opacity,
                      duration: Duration.zero,
                      child: Transform.translate(
                        offset: Offset(0, offset),
                        child: child,
                      ),
                    );
                  },
                  child: _MiniFabRow(
                    icon: action.icon,
                    label: action.label,
                    semanticsLabel: action.semanticsLabel,
                    onTap: action.onTap,
                  ),
                );
              }),

              // Main FAB
              const SizedBox(height: 12),
              Semantics(
                label: _isExpanded ? 'Close, button' : 'Add book, button',
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: FloatingActionButton(
                    heroTag: 'mainFab',
                    onPressed: _toggle,
                    tooltip: 'Add book',
                    child: Icon(_isExpanded ? Icons.close : Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single mini-FAB with a trailing label.
class _MiniFabRow extends StatelessWidget {
  const _MiniFabRow({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mini-FAB with guaranteed 48dp hit area
          Semantics(
            label: semanticsLabel,
            button: true,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
