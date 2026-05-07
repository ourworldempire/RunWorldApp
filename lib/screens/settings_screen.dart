import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/settings_provider.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/services/auth_service.dart';
import 'package:runworld/utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user     = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.textLight), onPressed: () => context.pop()),
                Text('SETTINGS', style: AppTextStyles.displayMD),
              ]),
              const SizedBox(height: AppSpacing.xl),

              // Profile card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: AppRadius.card),
                child: Row(children: [
                  Text(user?.avatar ?? '🏃', style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.name ?? 'Runner', style: AppTextStyles.bodyBoldLG),
                    Text(user?.email ?? '', style: AppTextStyles.bodySM),
                  ])),
                  TextButton(onPressed: () => context.push('/profile'), child: Text('Edit', style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent))),
                ]),
              ),

              const SizedBox(height: AppSpacing.xxl),
              _SectionLabel('PREFERENCES'),
              const SizedBox(height: AppSpacing.md),

              _ToggleRow(
                label: 'Notifications',
                icon: Icons.notifications_outlined,
                value: settings.notificationsEnabled,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
              ),
              _ToggleRow(
                label: 'Public Profile',
                icon: Icons.lock_open_outlined,
                value: settings.privacyPublic,
                onChanged: (_) => ref.read(settingsProvider.notifier).togglePrivacy(),
              ),

              const SizedBox(height: AppSpacing.xl),
              _SectionLabel('UNITS'),
              const SizedBox(height: AppSpacing.md),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.pill),
                child: Row(children: ['km', 'mi'].map((u) => Expanded(child: GestureDetector(
                  onTap: () => ref.read(settingsProvider.notifier).setUnits(u),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(color: settings.units == u ? AppColors.accent : Colors.transparent, borderRadius: AppRadius.pill),
                    alignment: Alignment.center,
                    child: Text(u, style: AppTextStyles.bodyBold.copyWith(color: settings.units == u ? AppColors.white : AppColors.textMuted)),
                  ),
                ))).toList()),
              ),

              const SizedBox(height: AppSpacing.xxl),
              _SectionLabel('ACCOUNT'),
              const SizedBox(height: AppSpacing.md),

              // Logout
              _ActionRow(
                label: 'Logout',
                icon: Icons.logout,
                color: AppColors.textLight,
                onTap: () {
                  final router = GoRouter.of(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.secondary,
                      title: Text('Logout?', style: AppTextStyles.displaySM),
                      content: Text('You will be signed out.', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted))),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await AuthService.instance.logout();
                            ref.read(userProvider.notifier).clearUser();
                            router.go('/onboarding');
                          },
                          child: Text('Logout', style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Delete account
              _ActionRow(
                label: 'Delete Account',
                icon: Icons.delete_forever_outlined,
                color: AppColors.error,
                onTap: () {
                  final router = GoRouter.of(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => _DeleteAccountDialog(
                      onConfirm: () async {
                        await AuthService.instance.deleteAccount();
                        ref.read(userProvider.notifier).clearUser();
                        router.go('/onboarding');
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.bodySM.copyWith(letterSpacing: 1.5));
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.icon, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: AppRadius.card),
    child: Row(children: [
      Icon(icon, color: AppColors.textMuted, size: 20),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Text(label, style: AppTextStyles.bodyLG)),
      Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.accent),
    ]),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;
  const _DeleteAccountDialog({required this.onConfirm});
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _deleting = false;
  String? _error;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.secondary,
    title: Text('Delete Account?', style: AppTextStyles.displaySM.copyWith(color: AppColors.error)),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This will permanently delete your account, all runs, and progress. This cannot be undone.',
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_error!, style: AppTextStyles.bodySM.copyWith(color: AppColors.error)),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: _deleting ? null : () => Navigator.pop(context),
        child: Text('Cancel', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
      ),
      TextButton(
        onPressed: _deleting ? null : () async {
          setState(() { _deleting = true; _error = null; });
          final nav = Navigator.of(context);
          try {
            await widget.onConfirm();
            nav.pop();
          } catch (e) {
            if (mounted) setState(() { _deleting = false; _error = e.toString().replaceFirst('Exception: ', ''); });
          }
        },
        child: _deleting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
            : Text('Delete', style: AppTextStyles.bodyBold.copyWith(color: AppColors.error)),
      ),
    ],
  );
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionRow({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: AppRadius.card),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTextStyles.bodyLG.copyWith(color: color)),
      ]),
    ),
  );
}
