// lib/pages/membership_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/membership_providers.dart';

class MembershipPage extends ConsumerWidget {
  const MembershipPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  String _ymd(DateTime? d) =>
      d == null ? '未設定' : '${d.year.toString().padLeft(4, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(membershipControllerProvider);
    final ctrl = ref.read(membershipControllerProvider.notifier);

    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FA);
    final panel = isDark ? const Color(0xFF151A20) : Colors.white;
    final border = isDark ? const Color(0xFF2A2F36) : const Color(0xFFE5E7EB);
    final labelC = t.colorScheme.onSurfaceVariant;
    final valueC = t.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: valueC,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _back(context),
        ),
        title: const Text('会員情報'),
        actions: [
          async.when(
            data: (s) => !s.editing
                ? TextButton.icon(
              onPressed: ctrl.toggleEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('編集する'),
            )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました：$e')),
        data: (s) {
          final f = s.form;
          return Form(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _sectionHeader(context, title: '会員情報', headerBg: bg, border: border),
                const SizedBox(height: 8),

                _panel(
                  panel: panel,
                  border: border,
                  child: Column(
                    children: [
                      _row(
                        context,
                        label: '名前',
                        labelColor: labelC,
                        child: s.editing
                            ? TextFormField(
                          initialValue: f.displayName,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '例）山田 太郎',
                          ),
                          onChanged: ctrl.setName,
                        )
                            : _valueText(context, f.displayName.isEmpty ? '-' : f.displayName, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '生年月日',
                        labelColor: labelC,
                        child: s.editing
                            ? InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final init = f.birthday ?? DateTime(now.year - 20, 1, 1);
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: init,
                              firstDate: DateTime(1900),
                              lastDate: now,
                              helpText: '生年月日を選択',
                              cancelText: 'キャンセル',
                              confirmText: '決定',
                              locale: const Locale('ja', 'JP'),
                            );
                            if (picked != null) ctrl.setBirthday(picked);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _ymd(f.birthday),
                                  style: t.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          ),
                        )
                            : _valueText(context, _ymd(f.birthday), valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '性別',
                        labelColor: labelC,
                        child: s.editing
                            ? DropdownButtonFormField<String>(
                          value: f.gender,
                          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: '未選択', child: Text('未選択')),
                            DropdownMenuItem(value: '男性', child: Text('男性')),
                            DropdownMenuItem(value: '女性', child: Text('女性')),
                          ],
                          onChanged: (v) => ctrl.setGender(v ?? '未選択'),
                        )
                            : _valueText(context, f.gender.isEmpty ? '未選択' : f.gender, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '郵便番号',
                        labelColor: labelC,
                        child: s.editing
                            ? TextFormField(
                          initialValue: f.postalCode,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '例）123-4567',
                          ),
                          onChanged: ctrl.setPostal,
                        )
                            : _valueText(context, f.postalCode, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '住所（都道府県・市区町村）',
                        labelColor: labelC,
                        child: s.editing
                            ? TextFormField(
                          initialValue: f.address1,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '例）東京都渋谷区〇〇',
                          ),
                          onChanged: ctrl.setAddr1,
                        )
                            : _valueText(context, f.address1, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '住所（番地・建物）',
                        labelColor: labelC,
                        child: s.editing
                            ? TextFormField(
                          initialValue: f.address2,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '例）1-2-3 〇〇ビル101',
                          ),
                          onChanged: ctrl.setAddr2,
                        )
                            : _valueText(context, f.address2, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '携帯電話',
                        labelColor: labelC,
                        child: s.editing
                            ? TextFormField(
                          initialValue: f.mobilePhone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '例）09012345678',
                          ),
                          onChanged: ctrl.setMobile,
                        )
                            : _valueText(context, f.mobilePhone, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: '固定電話',
                        labelColor: labelC,
                        child: s.editing
                            ? TextFormField(
                          initialValue: f.landlinePhone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '任意',
                          ),
                          onChanged: ctrl.setLandline,
                        )
                            : _valueText(context, f.landlinePhone, valueC),
                      ),
                      _divider(border),

                      _row(
                        context,
                        label: 'メールアドレス',
                        labelColor: labelC,
                        child: _valueText(context, f.email.isEmpty ? '-' : f.email, valueC),
                      ),
                    ],
                  ),
                ),

                if (s.editing) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: s.saving
                          ? null
                          : () async {
                        HapticFeedback.lightImpact();
                        await ctrl.save();
                        final after = ref.read(membershipControllerProvider);
                        if (after.hasError && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('保存に失敗しました：${after.error}')),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('会員情報を保存しました')),
                          );
                        }
                      },
                      icon: s.saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(s.saving ? '保存中…' : '保存する'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: s.saving ? null : ctrl.toggleEdit,
                      icon: const Icon(Icons.close),
                      label: const Text('編集をやめる'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ────────── ヘルパーUI ──────────

  Widget _sectionHeader(BuildContext context,
      {required String title, required Color headerBg, required Color border}) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Text(
        title,
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: t.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _panel({required Color panel, required Color border, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _divider(Color border) => Divider(height: 1, thickness: 1, color: border);

  /// ← BuildContext を引数で受けるように修正
  Widget _row(
      BuildContext context, {
        required String label,
        required Widget child,
        required Color labelColor,
      }) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: t.textTheme.bodyMedium?.copyWith(color: labelColor)),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// ← BuildContext を引数で受けるように修正
  Widget _valueText(BuildContext context, String value, Color color) {
    final t = Theme.of(context);
    final v = value.isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        v,
        style: t.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
