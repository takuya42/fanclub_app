// lib/providers/membership_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 会員フォーム（UI入力とFirestoreの橋渡し）
/// - 性別: '未選択' / '男性' / '女性' のみ
/// - 「国」は使わないので保持・保存しません
@immutable
class MembershipForm {
  final String displayName;
  final DateTime? birthday;
  final String gender;       // '未選択' / '男性' / '女性'
  final String postalCode;
  final String address1;
  final String address2;
  final String mobilePhone;
  final String landlinePhone;
  final String email;        // 参照表示用（通常はAuthの値）

  const MembershipForm({
    this.displayName = '',
    this.birthday,
    this.gender = '未選択',
    this.postalCode = '',
    this.address1 = '',
    this.address2 = '',
    this.mobilePhone = '',
    this.landlinePhone = '',
    this.email = '',
  });

  /// 性別の正規化
  static String _normalizeGender(String raw) {
    switch (raw.trim()) {
      case '男性':
      case '女性':
        return raw.trim();
      case '未選択':
      case '':
      default:
        return '未選択';
    }
  }

  MembershipForm copyWith({
    String? displayName,
    DateTime? birthday,
    String? gender,
    String? postalCode,
    String? address1,
    String? address2,
    String? mobilePhone,
    String? landlinePhone,
    String? email,
    bool birthdayToNull = false,
  }) {
    return MembershipForm(
      displayName: displayName ?? this.displayName,
      birthday: birthdayToNull ? null : (birthday ?? this.birthday),
      gender: gender == null ? this.gender : _normalizeGender(gender),
      postalCode: postalCode ?? this.postalCode,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      landlinePhone: landlinePhone ?? this.landlinePhone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toFirestore() {
    final normalizedGender = _normalizeGender(gender);
    return {
      'displayName': displayName,
      'birthday': birthday == null ? null : Timestamp.fromDate(birthday!),
      // Firestore上は空文字で未選択扱い
      'gender': normalizedGender == '未選択' ? '' : normalizedGender,
      'postalCode': postalCode,
      'address1': address1,
      'address2': address2,
      'mobilePhone': mobilePhone,
      'landlinePhone': landlinePhone,
      // email はAuth由来想定なので基本は書き込まない
    }..removeWhere((k, v) => v == null);
  }

  /// 🔹 Firestore → MembershipForm 変換（新旧キー両対応）
  static MembershipForm fromFirestore(Map<String, dynamic>? map, {String email = ''}) {
    final m = map ?? const {};
    DateTime? bd;
    final raw = m['birthday'];
    if (raw is Timestamp) bd = raw.toDate();
    if (raw is DateTime) bd = raw;

    // 性別正規化
    final rawGender = (m['gender'] ?? '') as String;
    final normalizedGender = _normalizeGender(rawGender);

    // 🔹 PaymentPage側の古いキー名にも対応（postal / address / phone）
    final postalCode = (m['postalCode'] ?? m['postal'] ?? '') as String;
    final address1 = (m['address1'] ?? m['address'] ?? '') as String;
    final address2 = (m['address2'] ?? '') as String;
    final mobilePhone = (m['mobilePhone'] ?? m['phone'] ?? '') as String;

    return MembershipForm(
      displayName: (m['displayName'] ?? '') as String,
      birthday: bd,
      gender: normalizedGender,
      postalCode: postalCode,
      address1: address1,
      address2: address2,
      mobilePhone: mobilePhone,
      landlinePhone: (m['landlinePhone'] ?? '') as String,
      email: email,
    );
  }
}

/// UI 状態（編集中/保存中 フラグ）
@immutable
class MembershipUiState {
  final MembershipForm form;
  final bool editing;
  final bool saving;

  const MembershipUiState({
    required this.form,
    this.editing = false,
    this.saving = false,
  });

  MembershipUiState copyWith({
    MembershipForm? form,
    bool? editing,
    bool? saving,
  }) {
    return MembershipUiState(
      form: form ?? this.form,
      editing: editing ?? this.editing,
      saving: saving ?? this.saving,
    );
  }
}

/// StateNotifier 本体
class MembershipController extends StateNotifier<AsyncValue<MembershipUiState>> {
  MembershipController(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref ref;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  String? get _uid => _auth.currentUser?.uid;

  /// 🔹 Firestoreからデータを読み込み（PaymentPageの保存データにも対応）
  Future<void> _load() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = AsyncValue.error('ログインが必要です', StackTrace.current);
        return;
      }

      final snap = await _db.collection('users').doc(user.uid).get();
      final form = MembershipForm.fromFirestore(snap.data(), email: user.email ?? '');
      state = AsyncValue.data(MembershipUiState(form: form));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void toggleEdit() {
    final val = state.valueOrNull;
    if (val == null) return;
    state = AsyncValue.data(val.copyWith(editing: !val.editing));
  }

  // --- setters ---
  void setName(String v)        => _patch(form: state.value!.form.copyWith(displayName: v));
  void setBirthday(DateTime? v) => _patch(form: state.value!.form.copyWith(birthday: v));
  void setGender(String v)      => _patch(form: state.value!.form.copyWith(gender: v));
  void setPostal(String v)      => _patch(form: state.value!.form.copyWith(postalCode: v));
  void setAddr1(String v)       => _patch(form: state.value!.form.copyWith(address1: v));
  void setAddr2(String v)       => _patch(form: state.value!.form.copyWith(address2: v));
  void setMobile(String v)      => _patch(form: state.value!.form.copyWith(mobilePhone: v));
  void setLandline(String v)    => _patch(form: state.value!.form.copyWith(landlinePhone: v));

  void _patch({required MembershipForm form}) {
    final val = state.valueOrNull;
    if (val == null) return;
    state = AsyncValue.data(val.copyWith(form: form));
  }

  /// 🔹 保存処理（Firestoreへマージ）
  Future<void> save() async {
    final val = state.valueOrNull;
    if (val == null || _uid == null) return;

    state = AsyncValue.data(val.copyWith(saving: true));
    try {
      await _db.collection('users').doc(_uid).set(
        val.form.toFirestore(),
        SetOptions(merge: true),
      );
      state = AsyncValue.data(val.copyWith(editing: false, saving: false));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reload() => _load();
}

/// Provider（UI はこれを watch するだけ）
final membershipControllerProvider =
StateNotifierProvider<MembershipController, AsyncValue<MembershipUiState>>(
      (ref) => MembershipController(ref),
);
