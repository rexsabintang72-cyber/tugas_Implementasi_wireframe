import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_models.dart';

class AppStorage {
  static const String _accountsKey = 'accounts';
  static const String _notesByAccountKey = 'notes_by_account';
  static const String _currentAccountEmailKey = 'current_account_email';
  static const String _themeModeKey = 'theme_mode';

  Future<PersistedAppState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final accountsJson = preferences.getString(_accountsKey);
    final notesByAccountJson = preferences.getString(_notesByAccountKey);
    final currentAccountEmail = preferences.getString(_currentAccountEmailKey);

    final accounts = _decodeAccounts(accountsJson);
    final notesByAccount = _decodeNotesByAccount(notesByAccountJson);

    return PersistedAppState(
      accounts: accounts,
      notesByAccount: notesByAccount,
      currentAccountEmail: currentAccountEmail,
    );
  }

  Future<void> save({
    required List<UserAccount> accounts,
    required Map<String, List<NoteItem>> notesByAccount,
    String? currentAccountEmail,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _accountsKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
    await preferences.setString(
      _notesByAccountKey,
      jsonEncode(
        notesByAccount.map(
          (email, notes) =>
              MapEntry(email, notes.map((note) => note.toJson()).toList()),
        ),
      ),
    );

    if (currentAccountEmail == null || currentAccountEmail.isEmpty) {
      await preferences.remove(_currentAccountEmailKey);
      return;
    }
    await preferences.setString(_currentAccountEmailKey, currentAccountEmail);
  }

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_themeModeKey);
    switch (storedValue) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    final value = themeMode == ThemeMode.dark ? 'dark' : 'light';
    await preferences.setString(_themeModeKey, value);
  }

  List<UserAccount> _decodeAccounts(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) {
      return const <UserAccount>[];
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => UserAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const <UserAccount>[];
    }
  }

  Map<String, List<NoteItem>> _decodeNotesByAccount(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) {
      return const <String, List<NoteItem>>{};
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return decoded.map((email, notes) {
        final noteList = (notes as List<dynamic>)
            .map((item) => NoteItem.fromJson(item as Map<String, dynamic>))
            .toList();
        return MapEntry(email, noteList);
      });
    } catch (_) {
      return const <String, List<NoteItem>>{};
    }
  }
}
