import 'package:flutter/material.dart';

import 'app_models.dart';
import 'app_theme.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.note, required this.onEdit});

  final NoteItem note;
  final Future<NoteItem?> Function(NoteItem note) onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppTheme.colorsOf(context);

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    _TopButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text('Detail Catatan', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    const _TopButton(icon: Icons.more_horiz_rounded),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [palette.primary, palette.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              note.category,
                              style: const TextStyle(
                                color: AppTheme.accentSoft,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            note.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Color(0xFFE2F6F2),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Diperbarui ${_formatDate(note.updatedAt)}',
                                style: const TextStyle(
                                  color: Color(0xFFE2F6F2),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Isi Catatan',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 14),
                          Text(note.content, style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: palette.backgroundSoft,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: palette.accent.withValues(
                                      alpha: 0.22,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: Color(0xFF826A16),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Catatan yang rapi membuat ide lebih mudah dilanjutkan dan dibagikan ke tim.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updatedNote = await onEdit(note);
                              if (!context.mounted || updatedNote == null) {
                                return;
                              }
                              Navigator.pop(context, DetailAction.updated);
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Catatan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Hapus catatan?'),
                                    content: const Text(
                                      'Catatan yang dihapus tidak bisa dikembalikan.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext, false);
                                        },
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext, true);
                                        },
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!context.mounted || shouldDelete != true) {
                                return;
                              }

                              Navigator.pop(context, DetailAction.deleted);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.danger,
                            ),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Hapus'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

enum DetailAction { updated, deleted }

class _TopButton extends StatelessWidget {
  const _TopButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppTheme.textPrimary, size: 20),
        ),
      ),
    );
  }
}
