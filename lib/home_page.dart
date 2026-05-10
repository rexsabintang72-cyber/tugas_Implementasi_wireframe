import 'package:flutter/material.dart';

import 'app_models.dart';
import 'app_storage.dart';
import 'app_theme.dart';
import 'detail_page.dart';
import 'login_page.dart';
import 'tambah_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _quickCategories = [
    'Prioritas',
    'Kuliah',
    'Project',
    'Ide Baru',
  ];

  final TextEditingController _searchController = TextEditingController();
  final AppStorage _appStorage = AppStorage();
  final List<UserAccount> _registeredAccounts = [];
  final Map<String, List<NoteItem>> _notesByAccount = {};
  UserAccount? _currentAccount;
  String? _selectedQuickCategory;
  bool _isSessionReady = false;
  final List<NoteItem> _guestNotes = [];

  @override
  void initState() {
    super.initState();
    _loadStoredState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  UserProfile? get _currentUser => _currentAccount?.toProfile();

  List<NoteItem> get _activeNotes {
    final currentAccount = _currentAccount;
    if (currentAccount == null) {
      return _guestNotes;
    }
    return _notesByAccount.putIfAbsent(
      currentAccount.email,
      () => <NoteItem>[],
    );
  }

  Future<void> _loadStoredState() async {
    try {
      final persistedState = await _appStorage.load();
      if (!mounted) {
        return;
      }

      setState(() {
        _registeredAccounts
          ..clear()
          ..addAll(persistedState.accounts);
        _notesByAccount
          ..clear()
          ..addAll(persistedState.notesByAccount);
        _currentAccount = _findAccountByEmail(
          persistedState.currentAccountEmail,
        );
        _isSessionReady = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSessionReady = true;
      });
    }
  }

  Future<void> _persistState() {
    return _appStorage.save(
      accounts: _registeredAccounts,
      notesByAccount: _notesByAccount,
      currentAccountEmail: _currentAccount?.email,
    );
  }

  UserAccount? _findAccountByEmail(String? email) {
    if (email == null || email.isEmpty) {
      return null;
    }

    for (final account in _registeredAccounts) {
      if (account.email.toLowerCase() == email.toLowerCase()) {
        return account;
      }
    }
    return null;
  }

  Future<void> _openCreatePage() async {
    final newNote = await Navigator.push<NoteItem>(
      context,
      MaterialPageRoute(builder: (_) => const TambahPage()),
    );

    if (newNote == null || !mounted) {
      return;
    }

    setState(() {
      _activeNotes.insert(0, newNote);
    });
    await _persistState();
    _showMessage('Catatan baru berhasil disimpan.');
  }

  Future<void> _openAuthPage() async {
    final authResult = await Navigator.push<AuthSessionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          registeredAccounts: List<UserAccount>.unmodifiable(
            _registeredAccounts,
          ),
          currentProfile: _currentUser,
        ),
      ),
    );

    if (authResult == null || !mounted) {
      return;
    }
    final existingIndex = _registeredAccounts.indexWhere(
      (account) =>
          account.email.toLowerCase() == authResult.account.email.toLowerCase(),
    );

    setState(() {
      if (existingIndex == -1) {
        _registeredAccounts.add(authResult.account);
        _notesByAccount[authResult.account.email] = <NoteItem>[];
      } else {
        _registeredAccounts[existingIndex] = authResult.account;
        _notesByAccount.putIfAbsent(
          authResult.account.email,
          () => <NoteItem>[],
        );
      }
      _currentAccount = authResult.account;
      _selectedQuickCategory = null;
      _searchController.clear();
    });
    await _persistState();
    _showMessage(authResult.message);
  }

  Future<void> _handleAvatarTap() async {
    if (_currentUser == null) {
      await _openAuthPage();
      return;
    }

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final palette = AppTheme.colorsOf(context);
        final parentContext = this.context;
        final user = _currentUser!;
        final otherAccounts = _registeredAccounts
            .where(
              (account) =>
                  account.email.toLowerCase() != user.email.toLowerCase(),
            )
            .toList();
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.primary, palette.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(user.email, style: theme.textTheme.bodyMedium),
                if (otherAccounts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Akun Tersimpan',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Ganti instan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...otherAccounts.map((account) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProfileAccountCard(
                        key: Key('profile_saved_account_${account.email}'),
                        account: account,
                        onTap: () async {
                          Navigator.pop(context);
                          await _requestAccountSwitch(parentContext, account);
                        },
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _openAuthPage();
                    },
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: const Text('Ganti Akun'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        _currentAccount = null;
                        _selectedQuickCategory = null;
                        _searchController.clear();
                      });
                      await _persistState();
                      _showMessage(
                        'Akun ini sudah logout. Akun lain tetap tersimpan.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.danger,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestAccountSwitch(
    BuildContext context,
    UserAccount account,
  ) async {
    String enteredPassword = '';
    bool obscurePassword = true;

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final palette = AppTheme.colorsOf(dialogContext);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Masuk ke ${account.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan password akun ini untuk melanjutkan perpindahan akun.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: Key('switch_account_password_${account.email}'),
                    obscureText: obscurePassword,
                    autofocus: true,
                    onChanged: (value) {
                      enteredPassword = value.trim();
                    },
                    decoration: InputDecoration(
                      hintText: 'Password akun',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      Navigator.pop(
                        dialogContext,
                        enteredPassword == account.password,
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      enteredPassword == account.password,
                    );
                  },
                  child: const Text('Masuk'),
                ),
              ],
            );
          },
        );
      },
    );

    if (isConfirmed != true) {
      if (mounted) {
        _showMessage('Password akun belum cocok.');
      }
      return;
    }

    await _switchAccountInstantly(account);
  }

  Future<void> _switchAccountInstantly(UserAccount account) async {
    setState(() {
      _currentAccount = account;
      _selectedQuickCategory = null;
      _searchController.clear();
    });
    await _persistState();
    _showMessage('Sekarang masuk sebagai ${account.name}.');
  }

  Future<void> _openDetailPage(NoteItem note, int index) async {
    final action = await Navigator.push<DetailAction>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          note: note,
          onEdit: (currentNote) => _openEditPage(currentNote),
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case DetailAction.deleted:
        setState(() {
          _activeNotes.removeAt(index);
        });
        await _persistState();
        _showMessage('Catatan berhasil dihapus.');
      case DetailAction.updated:
        setState(() {});
        await _persistState();
        _showMessage('Catatan berhasil diperbarui.');
    }
  }

  Future<NoteItem?> _openEditPage(NoteItem note) async {
    final updatedNote = await Navigator.push<NoteItem>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahPage(
          existingNote: note,
          submitLabel: 'Update Catatan',
          pageTitle: 'Edit Catatan',
          pageDescription: 'Perbarui isi catatan agar tetap akurat dan rapi.',
        ),
      ),
    );

    if (updatedNote == null || !mounted) {
      return null;
    }

    final noteIndex = _activeNotes.indexOf(note);
    if (noteIndex != -1) {
      setState(() {
        _activeNotes[noteIndex] = updatedNote;
      });
      await _persistState();
    }
    return updatedNote;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<NoteItem> get _filteredNotes {
    final query = _searchController.text.trim().toLowerCase();
    return _activeNotes.where((note) {
      final matchesCategory = _selectedQuickCategory == null
          ? true
          : note.category == _selectedQuickCategory;
      final matchesQuery = query.isEmpty
          ? true
          : note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query) ||
                note.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppTheme.colorsOf(context);

    if (!_isSessionReady) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.backgroundSoft, palette.background],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    key: const Key('session_loading_indicator'),
                    strokeWidth: 3,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Mengecek sesi akun...',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredNotes = _filteredNotes;
    final activeNotes = _activeNotes;
    final greeting = _currentUser == null
        ? 'Selamat datang kembali'
        : 'Halo, ${_currentUser!.name}';
    final workspaceLabel = _currentUser == null
        ? 'Tap avatar untuk login'
        : _currentUser!.email;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Catatan Baru'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.backgroundSoft, palette.background],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            children: [
              _Header(
                theme: theme,
                greeting: greeting,
                workspaceLabel: workspaceLabel,
                currentUser: _currentUser,
                onAvatarTap: _handleAvatarTap,
                isDarkMode: widget.themeMode == ThemeMode.dark,
                onThemeToggle: () {
                  final nextMode = widget.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  widget.onThemeModeChanged(nextMode);
                },
              ),
              const SizedBox(height: 24),
              _HighlightCard(totalNotes: activeNotes.length),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari ide, meeting, atau to-do penting...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Catatan',
                      value: '${activeNotes.length}',
                      accent: AppTheme.primary,
                      icon: Icons.auto_stories_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Hasil Pencarian',
                      value: '${filteredNotes.length}',
                      accent: AppTheme.secondary,
                      icon: Icons.visibility_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kategori Cepat', style: theme.textTheme.titleLarge),
                  Text(
                    _selectedQuickCategory ?? 'Semua',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickCategories.map((category) {
                  return _CategoryChip(
                    key: Key('quick_category_$category'),
                    label: category,
                    selected: _selectedQuickCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedQuickCategory =
                            _selectedQuickCategory == category
                            ? null
                            : category;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Catatan Terbaru', style: theme.textTheme.titleLarge),
                  Text(
                    '${filteredNotes.length} item',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (filteredNotes.isEmpty)
                const _EmptyState()
              else
                ...filteredNotes.map((item) {
                  final actualIndex = activeNotes.indexOf(item);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _NoteCard(
                      title: item.title,
                      content: item.content,
                      tag: item.category,
                      time: _formatTime(item.updatedAt),
                      icon: _iconForCategory(item.category),
                      onTap: () => _openDetailPage(item, actualIndex),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static IconData _iconForCategory(String category) {
    switch (category) {
      case 'Desain':
        return Icons.palette_outlined;
      case 'Produktif':
        return Icons.bolt_rounded;
      case 'Kolaborasi':
        return Icons.groups_rounded;
      case 'Project':
        return Icons.folder_open_rounded;
      case 'Kuliah':
        return Icons.school_rounded;
      case 'Prioritas':
        return Icons.flag_rounded;
      case 'Personal':
        return Icons.favorite_border_rounded;
      case 'Ide Baru':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.note_alt_outlined;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.theme,
    required this.greeting,
    required this.workspaceLabel,
    required this.currentUser,
    required this.onAvatarTap,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final ThemeData theme;
  final String greeting;
  final String workspaceLabel;
  final UserProfile? currentUser;
  final VoidCallback onAvatarTap;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.colorsOf(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: palette.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: palette.border.withValues(alpha: 0.9),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10146C72),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.lightPalette.primary,
                            AppTheme.lightPalette.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Workspace Catatan',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 33,
                          height: 0.96,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.4,
                          color: palette.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(workspaceLabel, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        Material(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            key: const Key('theme_toggle_button'),
            borderRadius: BorderRadius.circular(20),
            onTap: onThemeToggle,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: palette.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('profile_avatar_button'),
            borderRadius: BorderRadius.circular(26),
            onTap: onAvatarTap,
            child: Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.primaryDark, palette.secondary],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18146C72),
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 10,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: palette.backgroundSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (currentUser == null) ...[
                      Positioned(
                        top: 15,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 11,
                        child: Container(
                          width: 34,
                          height: 18,
                          decoration: BoxDecoration(
                            color: palette.secondary.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ] else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            currentUser!.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 7,
                      bottom: 7,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: currentUser == null
                              ? AppTheme.accent
                              : const Color(0xFF59C9A5),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.totalNotes});

  final int totalNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [palette.primary, palette.primaryDark],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A146C72),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.accentSoft,
                      size: 14,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Focus of the day',
                      style: TextStyle(
                        color: AppTheme.accentSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.north_east_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Tulis insight penting',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 29,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'dan simpan semua ide',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: palette.accentSoft,
              fontSize: 29,
              height: 1.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workspace yang lebih rapi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Susun ide, prioritas, dan proyek dalam satu tempat yang mudah dibaca.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD8F0EA),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroStatPill(
                  label: 'Active Notes',
                  value: '$totalNotes',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _HeroStatPill(label: 'Daily Flow', value: 'Fresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFCAE8E1),
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.colorsOf(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2A211B),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: palette.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.colorsOf(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? palette.secondary.withValues(alpha: 0.14)
                : palette.surface,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: selected ? palette.secondary : palette.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? palette.secondary : palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.colorsOf(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: palette.textMuted),
          const SizedBox(height: 12),
          Text(
            'Catatan tidak ditemukan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain atau tambahkan catatan baru.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProfileAccountCard extends StatelessWidget {
  const _ProfileAccountCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  final UserAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppTheme.colorsOf(context);
    final profile = account.toProfile();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.backgroundSoft.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondary],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(profile.email, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.swap_horiz_rounded, color: palette.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.content,
    required this.tag,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String content;
  final String tag;
  final String time;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.colorsOf(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: palette.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: palette.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: palette.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(content, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: palette.accentSoft,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12E7C96F),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF826A16),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
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
