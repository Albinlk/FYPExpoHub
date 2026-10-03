import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_users.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/layout/responsive.dart';

/// Users & Roles (backlog U2): search people, add / remove FYPMS roles
/// (optionally per programme), activate / deactivate accounts, and — for
/// administrators — change the account type. Every change is audited; the
/// coordinator role can only be granted by an administrator.
class CoordinatorUsersPage extends ConsumerStatefulWidget {
  const CoordinatorUsersPage({super.key});

  @override
  ConsumerState<CoordinatorUsersPage> createState() => _CoordinatorUsersPageState();
}

class _CoordinatorUsersPageState extends ConsumerState<CoordinatorUsersPage> {
  final _search = TextEditingController();
  List<ManagedUser>? _users;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await ref.read(userAdminProvider).search(_search.text.trim());
      if (mounted) setState(() => _users = users);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
      await _load();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  Future<void> _addRole(ManagedUser u) async {
    final picked = await showDialog<(String, String)>(context: context, builder: (_) => _AddRoleDialog(user: u));
    if (picked == null) return;
    final (role, programme) = picked;
    await _run(
      () => ref.read(userAdminProvider).setRole(u.id, role, programmeCode: programme, active: true),
      '${kAcademicRoleLabels[role]} added to ${u.displayName}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isFypAdminProvider);
    final users = _users;
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text('Users & Roles', style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.gutter),
        children: [
          TextField(
            key: const Key('users-search'),
            controller: _search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search name, email or matric',
              suffixIcon: IconButton(tooltip: 'Search', icon: const Icon(Icons.arrow_forward), onPressed: _load),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceSm),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) Text('Could not load users: $_error', style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
          if (users != null && users.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No users match.')),
          for (final u in users ?? const <ManagedUser>[])
            Card(
              margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.displayName, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                              Text('${u.email}${u.matricId == null ? '' : ' · ${u.matricId}'}',
                                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Semantics(
                          label: 'Account active for ${u.displayName}',
                          child: Switch(
                            key: Key('active-${u.email}'),
                            value: u.isActive,
                            onChanged: (v) async {
                              if (!v) {
                                final ok = await confirmAction(
                                  context,
                                  title: 'Deactivate ${u.displayName}?',
                                  message: 'They will be unable to sign in until you activate the account again.',
                                  confirmLabel: 'Deactivate',
                                  destructive: true,
                                );
                                if (!ok || !mounted) return;
                              }
                              await _run(
                                () => ref.read(userAdminProvider).setActive(u.id, v),
                                v ? '${u.displayName} activated.' : '${u.displayName} deactivated.',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: DesignSystem.spaceXs,
                      runSpacing: DesignSystem.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (isAdmin)
                          DropdownButton<String>(
                            key: Key('account-${u.email}'),
                            value: u.role,
                            items: const [
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
                              DropdownMenuItem(value: 'student', child: Text('Student')),
                            ],
                            onChanged: (v) async {
                              if (v == null || v == u.role) return;
                              final ok = await confirmAction(
                                context,
                                title: 'Change Account Type?',
                                message: '${u.displayName} will become a $v account. This changes what they can open.',
                                confirmLabel: 'Change Type',
                              );
                              if (!ok || !mounted) return;
                              await _run(() => ref.read(userAdminProvider).setAccountType(u.id, v), 'Account type changed.');
                            },
                          )
                        else
                          Chip(label: Text(u.role)),
                        for (final (role, programme) in u.roles)
                          InputChip(
                            label: Text('${kAcademicRoleLabels[role] ?? role}${programme.isEmpty ? '' : ' · $programme'}'),
                            deleteButtonTooltipMessage: 'Remove role',
                            onDeleted: role == 'fyp_coordinator' && !isAdmin
                                ? null
                                : () async {
                                    final label = kAcademicRoleLabels[role] ?? role;
                                    final ok = await confirmAction(
                                      context,
                                      title: 'Remove $label?',
                                      message: '${u.displayName} loses the $label role and its access.',
                                      confirmLabel: 'Remove Role',
                                      destructive: true,
                                    );
                                    if (!ok || !mounted) return;
                                    await _run(
                                      () => ref.read(userAdminProvider).setRole(u.id, role, programmeCode: programme, active: false),
                                      '$label removed.',
                                    );
                                  },
                          ),
                        TextButton.icon(
                          onPressed: () => _addRole(u),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add role'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddRoleDialog extends ConsumerStatefulWidget {
  const _AddRoleDialog({required this.user});
  final ManagedUser user;

  @override
  ConsumerState<_AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends ConsumerState<_AddRoleDialog> {
  String? _role;
  final _programme = TextEditingController();

  @override
  void dispose() {
    _programme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isFypAdminProvider);
    return AlertDialog(
      title: Text('Add role — ${widget.user.displayName}'),
      content: SizedBox(
        width: dialogWidth(context, 420),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              key: const Key('add-role'),
              initialValue: _role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Role'),
              items: [
                for (final e in kAcademicRoleLabels.entries)
                  if (e.key != 'fyp_coordinator' || isAdmin) DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _role = v),
            ),
            TextField(
              controller: _programme,
              decoration: const InputDecoration(
                labelText: 'Programme (optional)',
                helperText: 'e.g. CS266. Leave blank for every programme.',
              ),
            ),
          ],
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _role == null ? null : () => Navigator.pop(context, (_role!, _programme.text.trim().toUpperCase())),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
