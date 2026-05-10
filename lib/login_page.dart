import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.registeredAccounts,
    this.currentProfile,
  });

  final List<UserAccount> registeredAccounts;
  final UserProfile? currentProfile;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late bool _isRegisterMode;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.registeredAccounts.isEmpty;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController.addListener(_refresh);
    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
  }

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _emailController.removeListener(_refresh);
    _passwordController.removeListener(_refresh);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _hasRegisteredAccounts => widget.registeredAccounts.isNotEmpty;

  void _switchMode(bool isRegisterMode) {
    if (_isRegisterMode == isRegisterMode) {
      return;
    }

    setState(() {
      _isRegisterMode = isRegisterMode;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _selectAccount(UserAccount account) {
    setState(() {
      _isRegisterMode = false;
      _nameController.text = account.name;
      _emailController.text = account.email;
      _passwordController.clear();
    });
  }

  UserAccount? _findAccountByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final account in widget.registeredAccounts) {
      if (account.email.toLowerCase() == normalizedEmail) {
        return account;
      }
    }
    return null;
  }

  bool get _canSubmit {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final hasPassword = _passwordController.text.trim().isNotEmpty;
    return _isRegisterMode
        ? hasName && hasEmail && hasPassword
        : hasEmail && hasPassword;
  }

  void _submit() {
    if (!_canSubmit || !_formKey.currentState!.validate()) {
      return;
    }

    if (_isRegisterMode) {
      final existingAccount = _findAccountByEmail(_emailController.text);
      if (existingAccount != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Email ini sudah terdaftar. Silakan login atau pakai email lain.',
              ),
            ),
          );
        return;
      }

      final account = UserAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pop(
        context,
        AuthSessionResult(
          account: account,
          profile: account.toProfile(),
          message: 'Akun berhasil dibuat. Selamat datang, ${account.name}.',
        ),
      );
      return;
    }

    final account = _findAccountByEmail(_emailController.text);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (account == null ||
        email.toLowerCase() != account.email.toLowerCase() ||
        password != account.password) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Email atau password belum cocok dengan akun yang terdaftar.',
            ),
          ),
        );
      return;
    }

    Navigator.pop(
      context,
      AuthSessionResult(
        account: account,
        profile: account.toProfile(),
        message: 'Login berhasil. Selamat datang kembali, ${account.name}.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppTheme.colorsOf(context);
    final title = _isRegisterMode ? 'Register Akun' : 'Login Akun';
    final subtitle = _isRegisterMode
        ? 'Buat akun baru kapan pun supaya kamu bisa punya lebih dari satu workspace akun.'
        : 'Masuk menggunakan salah satu akun yang sudah kamu daftarkan sebelumnya.';
    final heroTitle = _isRegisterMode
        ? 'Buat akun baru'
        : 'Selamat datang lagi';
    final helperText = _isRegisterMode
        ? 'Setiap akun menyimpan catatan masing-masing, jadi kamu bisa gonta-ganti akun tanpa data saling tercampur.'
        : 'Login ke akun yang berbeda akan menampilkan catatan milik akun itu saja.';

    return Scaffold(
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Row(
                children: [
                  Material(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: palette.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(subtitle, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: palette.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F183234),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.lightPalette.primary,
                              AppTheme.lightPalette.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(heroTitle, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(helperText, style: theme.textTheme.bodyMedium),
                      if (_hasRegisteredAccounts) ...[
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: palette.backgroundSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _AuthModeButton(
                                  key: const Key('auth_mode_login'),
                                  label: 'Login',
                                  selected: !_isRegisterMode,
                                  onTap: () => _switchMode(false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _AuthModeButton(
                                  key: const Key('auth_mode_register'),
                                  label: 'Register',
                                  selected: _isRegisterMode,
                                  onTap: () => _switchMode(true),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_hasRegisteredAccounts && !_isRegisterMode) ...[
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Akun Tersimpan',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'Pilih akun',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: palette.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...widget.registeredAccounts.map((account) {
                          final isSelected =
                              _emailController.text.trim().toLowerCase() ==
                              account.email.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SavedAccountCard(
                              key: Key('saved_account_${account.email}'),
                              account: account,
                              selected: isSelected,
                              onTap: () => _selectAccount(account),
                            ),
                          );
                        }),
                      ],
                      if (_isRegisterMode) ...[
                        const SizedBox(height: 22),
                        Text(
                          'Nama Lengkap',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          key: const Key('login_name_field'),
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Joko Prasetyo',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama wajib diisi.';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text('Email', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: const Key('login_email_field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'nama@email.com',
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty || !email.contains('@')) {
                            return 'Email valid wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Text('Password', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: const Key('login_password_field'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password minimal 6 karakter.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: palette.backgroundSoft,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: palette.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.shield_outlined,
                                color: palette.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _isRegisterMode
                                    ? 'Isi semua field register dulu. Akun baru akan tersimpan lokal dan tetap bisa ditambahkan lagi walau kamu sudah punya akun lain.'
                                    : 'Tombol login hanya aktif saat email dan password terisi, lalu akan dicek ke daftar akun yang sudah tersimpan.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          key: const Key('login_submit_button'),
                          onPressed: _canSubmit ? _submit : null,
                          icon: Icon(
                            _isRegisterMode
                                ? Icons.app_registration_rounded
                                : Icons.login_rounded,
                          ),
                          label: Text(
                            _isRegisterMode
                                ? 'Daftar Sekarang'
                                : 'Masuk Sekarang',
                          ),
                        ),
                      ),
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

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? AppTheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: selected ? Border.all(color: AppTheme.border) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: selected ? AppTheme.primary : AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedAccountCard extends StatelessWidget {
  const _SavedAccountCard({
    super.key,
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final UserAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.secondary.withValues(alpha: 0.12)
                : AppTheme.backgroundSoft.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppTheme.secondary : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    account.toProfile().initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(account.email, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: selected ? 22 : 16,
                color: selected ? AppTheme.secondary : AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
