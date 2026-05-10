import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:helloworld/main.dart';

Future<void> scrollUntilTextVisible(
  WidgetTester tester,
  String text, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    find.text(text),
    delta,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> registerAccount(
  WidgetTester tester, {
  required String name,
  required String email,
  required String password,
  bool openRegisterMode = false,
}) async {
  if (openRegisterMode) {
    await tester.tap(find.byKey(const Key('auth_mode_register')));
    await tester.pumpAndSettle();
  }

  await tester.enterText(find.byKey(const Key('login_name_field')), name);
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    password,
  );
  await tester.pump();
  await tester.tap(find.byKey(const Key('login_submit_button')));
  await tester.pumpAndSettle();
}

Future<void> loginAccount(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    password,
  );
  await tester.pump();
  await tester.tap(find.byKey(const Key('login_submit_button')));
  await tester.pumpAndSettle();
}

Future<void> createNote(
  WidgetTester tester, {
  required String title,
  required String content,
  String? category,
}) async {
  await tester.tap(find.text('Catatan Baru'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), title);
  await tester.enterText(find.byType(TextFormField).at(1), content);
  if (category != null) {
    await tester.tap(find.text(category));
    await tester.pumpAndSettle();
  }
  await scrollUntilTextVisible(tester, 'Simpan Catatan');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Catatan'));
  await tester.pumpAndSettle();
}

Future<void> pumpFreshApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home page shows the redesigned notes experience', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Workspace Catatan'), findsOneWidget);
    expect(find.text('Catatan Baru'), findsOneWidget);
    expect(find.text('Focus of the day'), findsOneWidget);
    expect(find.text('0 item'), findsWidgets);
    expect(find.text('Catatan tidak ditemukan'), findsOneWidget);
  });

  testWidgets('floating action button opens the add note page', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Catatan'), findsOneWidget);
    expect(find.text('Simpan Catatan'), findsOneWidget);
  });

  testWidgets('user can add a new note', (WidgetTester tester) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await createNote(
      tester,
      title: 'Catatan Baru Saya',
      content: 'Isi catatan baru yang disimpan dari pengujian.',
    );

    expect(find.text('Catatan Baru Saya'), findsOneWidget);
    expect(find.text('Catatan baru berhasil disimpan.'), findsOneWidget);
  });

  testWidgets('user can edit an existing note', (WidgetTester tester) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );
    await createNote(
      tester,
      title: 'Belajar Flutter',
      content: 'Hari ini belajar UI Flutter.',
    );

    await tester.tap(find.text('Belajar Flutter'));
    await tester.pumpAndSettle();

    await scrollUntilTextVisible(tester, 'Edit Catatan');
    await tester.tap(find.text('Edit Catatan'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Belajar Flutter Lanjut',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Isi catatan sudah diperbarui lewat flow edit.',
    );
    await scrollUntilTextVisible(tester, 'Update Catatan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Update Catatan'));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.text('Belajar Flutter Lanjut'), findsOneWidget);
    expect(find.text('Catatan berhasil diperbarui.'), findsOneWidget);
  });

  testWidgets('user can delete an existing note', (WidgetTester tester) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );
    await createNote(
      tester,
      title: 'Meeting',
      content: 'Diskusi project kelompok.',
    );

    await tester.tap(find.text('Meeting'));
    await tester.pumpAndSettle();

    await scrollUntilTextVisible(tester, 'Hapus');
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();

    expect(find.text('Meeting'), findsNothing);
    expect(find.text('Catatan berhasil dihapus.'), findsOneWidget);
  });

  testWidgets('user must register first before login', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();

    expect(find.text('Register Akun'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('login_submit_button')))
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const Key('login_name_field')),
      'Joko Prasetyo',
    );
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'joko@email.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'rahasia123',
    );
    await tester.pump();
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('login_submit_button')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Joko Prasetyo'), findsOneWidget);
    expect(find.text('joko@email.com'), findsOneWidget);
    expect(find.text('JP'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();

    expect(find.text('Login Akun'), findsOneWidget);
    expect(find.byKey(const Key('login_name_field')), findsNothing);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('login_submit_button')))
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'joko@email.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'rahasia123',
    );
    await tester.pump();
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('login_submit_button')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Joko Prasetyo'), findsOneWidget);
  });

  testWidgets('user can switch accounts and notes stay with each account', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Catatan Akun Joko',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Data ini hanya untuk akun pertama.',
    );
    await scrollUntilTextVisible(tester, 'Simpan Catatan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Catatan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Akun Joko'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    expect(find.text('Login Akun'), findsOneWidget);
    await registerAccount(
      tester,
      name: 'Alya Putri',
      email: 'alya@email.com',
      password: 'password456',
      openRegisterMode: true,
    );

    expect(find.text('Halo, Alya Putri'), findsOneWidget);
    expect(find.text('Catatan Akun Joko'), findsNothing);
    expect(find.text('Belajar Flutter'), findsNothing);
    expect(find.text('0 item'), findsWidgets);

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Catatan Alya');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Catatan milik akun kedua.',
    );
    await scrollUntilTextVisible(tester, 'Simpan Catatan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Catatan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Alya'), findsOneWidget);
    expect(find.text('Catatan Akun Joko'), findsNothing);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved_account_joko@email.com')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('saved_account_joko@email.com')),
        matching: find.text('Joko Prasetyo'),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login_email_field')))
          .controller
          ?.text,
      'joko@email.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'rahasia123',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Akun Joko'), findsOneWidget);
    expect(find.text('Catatan Alya'), findsNothing);
  });

  testWidgets('saved accounts can be selected from login page', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Alya Putri',
      email: 'alya@email.com',
      password: 'password456',
      openRegisterMode: true,
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();

    expect(find.text('Akun Tersimpan'), findsOneWidget);
    expect(
      find.byKey(const Key('saved_account_joko@email.com')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('saved_account_alya@email.com')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('saved_account_alya@email.com')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login_email_field')))
          .controller
          ?.text,
      'alya@email.com',
    );

    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'password456',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Alya Putri'), findsOneWidget);
  });

  testWidgets('instant switch from profile also switches note data', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Catatan Joko Instan',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Catatan untuk akun Joko.',
    );
    await scrollUntilTextVisible(tester, 'Simpan Catatan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Catatan'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Alya Putri',
      email: 'alya@email.com',
      password: 'password456',
      openRegisterMode: true,
    );

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Catatan Alya Instan',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Catatan untuk akun Alya.',
    );
    await scrollUntilTextVisible(tester, 'Simpan Catatan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Catatan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Alya Instan'), findsOneWidget);
    expect(find.text('Catatan Joko Instan'), findsNothing);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('profile_saved_account_joko@email.com')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('profile_saved_account_joko@email.com')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Joko Prasetyo'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('switch_account_password_joko@email.com')),
      'rahasia123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Joko Prasetyo'), findsOneWidget);
    expect(find.text('Catatan Joko Instan'), findsOneWidget);
    expect(find.text('Catatan Alya Instan'), findsNothing);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('profile_saved_account_alya@email.com')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('profile_saved_account_alya@email.com')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Alya Putri'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('switch_account_password_alya@email.com')),
      'password456',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Alya Putri'), findsOneWidget);
    expect(find.text('Catatan Alya Instan'), findsOneWidget);
    expect(find.text('Catatan Joko Instan'), findsNothing);
  });

  testWidgets('profile switch requires correct password', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Alya Putri',
      email: 'alya@email.com',
      password: 'password456',
      openRegisterMode: true,
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('profile_saved_account_joko@email.com')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('switch_account_password_joko@email.com')),
      'salah123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Password akun belum cocok.'), findsOneWidget);
    expect(find.text('Halo, Alya Putri'), findsOneWidget);
    expect(find.text('Halo, Joko Prasetyo'), findsNothing);
  });

  testWidgets('quick category chips can filter notes', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await createNote(
      tester,
      title: 'Sprint Project',
      content: 'Catatan untuk project.',
      category: 'Project',
    );
    await createNote(
      tester,
      title: 'Belajar Flutter',
      content: 'Catatan untuk kuliah Flutter.',
      category: 'Kuliah',
    );
    await createNote(
      tester,
      title: 'Konsep Fitur Baru',
      content: 'Catatan ide baru.',
      category: 'Ide Baru',
    );

    await tester.tap(find.byKey(const Key('quick_category_Project')));
    await tester.pumpAndSettle();

    expect(find.text('Sprint Project'), findsOneWidget);
    expect(find.text('Belajar Flutter'), findsNothing);

    await tester.tap(find.byKey(const Key('quick_category_Project')));
    await tester.pumpAndSettle();

    await scrollUntilTextVisible(tester, 'Belajar Flutter', delta: 150);
    expect(find.text('Belajar Flutter'), findsOneWidget);
    await scrollUntilTextVisible(tester, 'Konsep Fitur Baru', delta: 150);
    expect(find.text('Konsep Fitur Baru'), findsOneWidget);
  });

  testWidgets('accounts and notes persist after app restart', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Catatan Persisten',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Catatan ini harus tetap ada setelah aplikasi dibuka lagi.',
    );
    await scrollUntilTextVisible(tester, 'Simpan Catatan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Catatan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Persisten'), findsOneWidget);
    expect(find.text('Halo, Joko Prasetyo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Halo, Joko Prasetyo'), findsOneWidget);
    expect(find.text('Catatan Persisten'), findsOneWidget);
  });

  testWidgets('logged out state starts with empty notes', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Tap avatar untuk login'), findsOneWidget);
    expect(find.text('0 item'), findsWidgets);
    expect(find.text('Catatan tidak ditemukan'), findsOneWidget);
  });

  testWidgets('theme mode can switch and persist after restart', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme_toggle_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
  });

  testWidgets('startup checks saved session before showing logged out state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'accounts':
          '[{"name":"Joko Prasetyo","email":"joko@email.com","password":"rahasia123"}]',
      'notes_by_account': '{}',
      'current_account_email': 'joko@email.com',
    });
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(const MyApp());

    expect(find.byKey(const Key('session_loading_indicator')), findsOneWidget);
    expect(find.text('Tap avatar untuk login'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Halo, Joko Prasetyo'), findsOneWidget);
    expect(find.text('Tap avatar untuk login'), findsNothing);
  });

  testWidgets('logout only removes current account session', (
    WidgetTester tester,
  ) async {
    await pumpFreshApp(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Joko Prasetyo',
      email: 'joko@email.com',
      password: 'rahasia123',
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(
      find.text('Akun ini sudah logout. Akun lain tetap tersimpan.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await registerAccount(
      tester,
      name: 'Alya Putri',
      email: 'alya@email.com',
      password: 'password456',
      openRegisterMode: true,
    );

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('saved_account_joko@email.com')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('saved_account_alya@email.com')),
      findsOneWidget,
    );
    expect(find.text('Login Akun'), findsOneWidget);
  });
}
