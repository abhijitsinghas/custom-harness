/// Setup wizard screen shown on first launch.
/// Workstream 2.1 (F0): 3-step wizard with Google Sign-In, library connection,
/// and sync progress.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../data/auth/auth_state_provider.dart';
import 'setup_state.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

const double _largeScreenMinWidth = 600.0;
const int _syncTotalBooks = 847;
const int _syncTotalLocations = 12;

// ─── Setup Screen ──────────────────────────────────────────────────────────

/// Setup wizard screen shown on first launch.
/// US-0.4.9: /setup route — 3-step wizard.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  late PageController _pageController;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Listen to step changes to sync the PageView.
  }

  @override
  void dispose() {
    _pageController.dispose();
    _syncTimer?.cancel();
    super.dispose();
  }

  void _onStepChanged(SetupStep step) {
    _pageController.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startSyncSimulation() {
    _syncTimer?.cancel();

    var progress = 0.0;
    const stages = [
      (0.0, SyncStage.downloading),
      (0.25, SyncStage.organizing),
      (0.50, SyncStage.fetchingCovers),
      (0.75, SyncStage.finalizing),
      (1.0, SyncStage.complete),
    ];
    var stageIndex = 0;

    _syncTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      progress += 0.04 + (0.02 * (stageIndex + 1));
      if (progress > 1.0) progress = 1.0;

      // Determine current stage based on progress.
      if (progress >= 1.0 && stageIndex < stages.length - 1) {
        stageIndex = stages.length - 1;
      } else if (progress >= 0.75 && stageIndex < 3) {
        stageIndex = 3;
      } else if (progress >= 0.50 && stageIndex < 2) {
        stageIndex = 2;
      } else if (progress >= 0.25 && stageIndex < 1) {
        stageIndex = 1;
      }

      ref.read(setupWizardProvider.notifier).updateSyncProgress(progress);
      ref
          .read(setupWizardProvider.notifier)
          .updateSyncStage(stages[stageIndex].$2);

      if (progress >= 1.0) {
        timer.cancel();
        ref.read(setupWizardProvider.notifier).completeSync(
              books: _syncTotalBooks,
              locations: _syncTotalLocations,
            );
      }
    });
  }

  void _onGoToCatalog() {
    _syncTimer?.cancel();
    if (!mounted) return;
    context.go(kRouteCatalog);
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(setupWizardProvider);

    // Sync page controller with state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != setupState.currentStep.index) {
        _pageController.animateToPage(
          setupState.currentStep.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Little Library'),
        automaticallyImplyLeading: false,
      ),
      body: _Body(
        pageController: _pageController,
        onStepChanged: _onStepChanged,
        onStartSync: _startSyncSimulation,
        onGoToCatalog: _onGoToCatalog,
      ),
    );
  }
}

/// Body with PageView and step indicator.
class _Body extends StatelessWidget {
  const _Body({
    required this.pageController,
    required this.onStepChanged,
    required this.onStartSync,
    required this.onGoToCatalog,
  });

  final PageController pageController;
  final void Function(SetupStep) onStepChanged;
  final VoidCallback onStartSync;
  final VoidCallback onGoToCatalog;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step indicator dots.
        Semantics(
          label: 'Setup wizard progress',
          child: const _StepDots(),
        ),
        // PageView with the 3 steps.
        Expanded(
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              onStepChanged(SetupStep.values[index]);
              if (index == SetupStep.sync.index) {
                onStartSync();
              }
            },
            children: [
              _Step1Welcome(onGoToCatalog: onGoToCatalog),
              _Step2Connect(onGoToCatalog: onGoToCatalog),
              _Step3Sync(onGoToCatalog: onGoToCatalog),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Step Indicator Dots ───────────────────────────────────────────────────

class _StepDots extends ConsumerWidget {
  const _StepDots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(setupWizardProvider);
    final currentStep = setupState.currentStep;
    final isComplete = setupState.syncStage == SyncStage.complete;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          SetupStep.values.length,
          (index) {
            final step = SetupStep.values[index];
            final isActive = step == currentStep;
            final isCompleted =
                isComplete || step.index < currentStep.index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isCompleted && !isActive
                    ? const Icon(
                        Icons.check,
                        size: 8,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Step 1: Welcome ──────────────────────────────────────────────────────

class _Step1Welcome extends ConsumerWidget {
  const _Step1Welcome({required this.onGoToCatalog});

  final VoidCallback onGoToCatalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > _largeScreenMinWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 400 : double.infinity,
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // App logo.
                Semantics(
                  label: 'The Little Library app icon',
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Heading.
                const Text(
                  'Welcome to The Little Library',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subheading.
                const Text(
                  'Catalog your family\'s books. '
                  'Never buy a duplicate again.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Google Sign-In button.
                const _SignInWithGoogleButton(),
                const SizedBox(height: 16),
                // Skip link.
                Semantics(
                  label: 'Skip sign-in for now',
                  child: TextButton(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).skip();
                      ref.read(setupWizardProvider.notifier).skipSignIn();
                    },
                    child: const Text('Skip for now'),
                  ),
                ),
                const SizedBox(height: 16),
                // Sign-in error message.
                const _SignInError(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Google Sign-In button widget.
class _SignInWithGoogleButton extends ConsumerWidget {
  const _SignInWithGoogleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Sign in with Google',
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.tonalIcon(
          onPressed: () async {
            ref.read(setupWizardProvider.notifier).clearSignInError();
            try {
              await ref.read(authStateProvider.notifier).signIn();
              final authState = ref.read(authStateProvider);
              if (authState is AuthSignedIn) {
                ref.read(setupWizardProvider.notifier).onSignInSuccess();
              } else {
                ref
                    .read(setupWizardProvider.notifier)
                    .onSignInFailure('Sign-in failed. Please try again.');
              }
            } catch (_) {
              ref
                  .read(setupWizardProvider.notifier)
                  .onSignInFailure('Sign-in failed. Please try again.');
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 1,
          ),
          icon: const SvgGoogleLogo(),
          label: const Text(
            'Sign in with Google',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

/// Simple Google logo using built-in shapes (no external SVG dependency).
class SvgGoogleLogo extends StatelessWidget {
  const SvgGoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Simplified Google "G" using colored arcs.
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue arc (top-left)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.2,
      false,
      paint,
    );

    // Red arc (bottom-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.5,
      1.0,
      false,
      paint,
    );

    // Yellow arc (bottom-right)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.0,
      1.2,
      false,
      paint,
    );

    // Green arc (top-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.2,
      1.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sign-in error message display.
class _SignInError extends ConsumerWidget {
  const _SignInError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(setupWizardProvider).syncError;
    if (error == null) return const SizedBox.shrink();

    return Text(
      error,
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ─── Step 2: Connect ──────────────────────────────────────────────────────

class _Step2Connect extends StatelessWidget {
  const _Step2Connect({required this.onGoToCatalog});

  final VoidCallback onGoToCatalog;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > _largeScreenMinWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 500 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connect to your family library',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose how you want to get started.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Option cards.
                const _OptionCards(),
                const SizedBox(height: 16),
                // Share family panel (shown after "Create Library" tapped).
                const _ShareFamilyPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Option cards: Join via link/QR and Create new library.
class _OptionCards extends ConsumerWidget {
  const _OptionCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Column(
      children: [
        // "I have a link or QR code" card.
        _buildOptionCard(
          context: context,
          isSelected:
              setupState.selectedConnectionMethod == LibraryConnectionMethod.joinViaLink,
          title: 'I have a link or QR code',
          subtitle:
              'Paste an invite link or scan a QR code from a family member.',
          onTap: () => notifier.selectJoinViaLink(),
          child: setupState.selectedConnectionMethod ==
                  LibraryConnectionMethod.joinViaLink
              ? const _LinkInputPanel()
              : null,
        ),
        const SizedBox(height: 12),
        // "Create a new library" card.
        _buildOptionCard(
          context: context,
          isSelected:
              setupState.selectedConnectionMethod == LibraryConnectionMethod.createNew,
          title: 'Create a new library',
          subtitle: 'Start fresh and invite your family later.',
          onTap: () => notifier.selectCreateNew(),
          child: setupState.selectedConnectionMethod ==
                  LibraryConnectionMethod.createNew
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => notifier.createLibrary(),
                      child: const Text('Create Library'),
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13),
            ),
            if (child != null) ...[
              const SizedBox(height: 4),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// Link input panel shown when "I have a link or QR code" is selected.
class _LinkInputPanel extends ConsumerWidget {
  const _LinkInputPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                onChanged: notifier.setInviteLink,
                decoration: InputDecoration(
                  hintText: 'Paste invite link here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: setupState.linkError,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // QR scan button.
            SizedBox(
              width: 48,
              height: 48,
              child: Semantics(
                label: 'Scan QR Code',
                child: IconButton.filledTonal(
                  onPressed: () {
                    // Simulate QR scan — populate with a sample URL.
                    notifier.onQRCodeScanned(
                      'https://littlelibrary.app/join/family-abc123',
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 22),
                  tooltip: 'Scan QR Code',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () => notifier.joinLibrary(),
            child: const Text('Join Library'),
          ),
        ),
      ],
    );
  }
}

/// Share with family panel shown after "Create Library" is tapped.
class _ShareFamilyPanel extends ConsumerWidget {
  const _ShareFamilyPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(setupWizardProvider);
    if (!setupState.showSharePanel) return const SizedBox.shrink();

    final notifier = ref.read(setupWizardProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share with family?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Invite others to collaborate on your library.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: notifier.setInviteEmails,
            decoration: InputDecoration(
              hintText: 'Enter email addresses',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.tonal(
              onPressed: () => notifier.sendInvites(),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text('Send Invites'),
            ),
          ),
          Center(
            child: Semantics(
              label: 'Skip sign-in for now',
              child: TextButton(
                onPressed: () => notifier.skipInvites(),
                child: const Text('Skip for now'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Sync ─────────────────────────────────────────────────────────

class _Step3Sync extends ConsumerWidget {
  const _Step3Sync({required this.onGoToCatalog});

  final VoidCallback onGoToCatalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    // Announce step to accessibility services.
    Semantics(
      label: setupState.stepAccessibilityLabel,
      child: const SizedBox.shrink(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > _largeScreenMinWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 400 : double.infinity,
            ),
            child: Column(
              children: [
                if (setupState.syncStage == SyncStage.complete)
                  _SyncComplete(onGoToCatalog: onGoToCatalog)
                else if (setupState.syncStage == SyncStage.error)
                  _SyncError(
                    message: setupState.syncError ?? 'Sync error',
                    onRetry: () {
                      notifier.markSyncError('');
                      notifier.updateSyncStage(SyncStage.downloading);
                      notifier.updateSyncProgress(0.0);
                    },
                  )
                else if (setupState.syncStage == SyncStage.offline)
                  const _SyncOffline()
                else
                  _SyncInProgress(
                    progress: setupState.syncProgress,
                    stageMessage: setupState.syncStageMessage,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Sync in progress widget.
class _SyncInProgress extends StatelessWidget {
  const _SyncInProgress({
    required this.progress,
    required this.stageMessage,
  });

  final double progress;
  final String stageMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Spinning sync icon.
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const _SpinningIcon(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Syncing your library…',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Progress bar.
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor:
                  Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          stageMessage,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        // Announce milestones for accessibility.
        if (progress >= 0.25 && progress < 0.30)
          Semantics(
            label: 'Syncing library, 25 percent complete.',
            child: const SizedBox.shrink(),
          ),
        if (progress >= 0.50 && progress < 0.55)
          Semantics(
            label: 'Syncing library, 50 percent complete.',
            child: const SizedBox.shrink(),
          ),
        if (progress >= 0.75 && progress < 0.80)
          Semantics(
            label: 'Syncing library, 75 percent complete.',
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}

/// Spinning icon animation for sync in progress.
class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon();

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.sync,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Sync complete widget with checkmark and stats.
class _SyncComplete extends StatelessWidget {
  const _SyncComplete({required this.onGoToCatalog});

  final VoidCallback onGoToCatalog;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final setupState = ref.watch(setupWizardProvider);

        return Column(
          children: [
            const SizedBox(height: 24),
            // Green checkmark.
            Semantics(
              label: 'Sync complete',
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You\'re all set!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              setupState.syncStats,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Semantics(
              label: 'Start Browsing',
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onGoToCatalog,
                  child: const Text('Start Browsing'),
                ),
              ),
            ),
            // Announce completion for accessibility.
            Semantics(
              label:
                  'Sync complete. ${setupState.syncedBooks} books synced. Start Browsing button.',
              child: const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

/// Sync error widget.
class _SyncError extends StatelessWidget {
  const _SyncError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: 40,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}

/// Sync offline widget.
class _SyncOffline extends StatelessWidget {
  const _SyncOffline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Amber offline indicator.
        Semantics(
          label: 'Offline — your library will sync when you\'re back online.',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off,
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'You\'re all set!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Offline — your library will sync when you\'re back online.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Semantics(
          label: 'Start Browsing',
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () {
                // Navigate to catalog.
              },
              child: const Text('Start Browsing'),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Post-setup banner for skipped sign-in ─────────────────────────────────

/// Banner shown on catalog screen when user skipped sign-in.
/// Displays "Sign in to sync with family" with a Settings link.
class PostSetupBanner extends ConsumerWidget {
  const PostSetupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final setupState = ref.watch(setupWizardProvider);

    // Only show if user skipped sign-in and is not signed in.
    if (!setupState.hasSkippedSignIn || authState is AuthSignedIn) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () {
          // Navigate to settings for sign-in.
          context.push(kRouteSettings);
        },
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.login,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sign in to sync with family',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
