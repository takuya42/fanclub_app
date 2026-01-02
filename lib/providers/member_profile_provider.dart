// lib/providers/member_profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class MemberProfile {
  final String displayName;     // 表示名
  final DateTime? birthday;     // 生年月日
  final String gender;          // 性別
  final String country;         // 国
  final String postalCode;      // 郵便番号
  final String address1;        // 住所1（都道府県・市区町村）
  final String address2;        // 住所2（番地・建物）
  final String mobilePhone;     // 連絡用携帯
  final String landlinePhone;   // 連絡用固定
  final String email;           // メール
  final String? accountId;      // @xxxx

  const MemberProfile({
    required this.displayName,
    required this.birthday,
    required this.gender,
    required this.country,
    required this.postalCode,
    required this.address1,
    required this.address2,
    required this.mobilePhone,
    required this.landlinePhone,
    required this.email,
    required this.accountId,
  });
}

String _strOrEmpty(Object? v) => (v is String) ? v : '';

DateTime? _tsToDate(Object? v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}

String formatYmd(DateTime? d) {
  if (d == null) return '';
  // 例: 1995 / 04 / 02
  return '${d.year.toString().padLeft(4, '0')} / '
      '${d.month.toString().padLeft(2, '0')} / '
      '${d.day.toString().padLeft(2, '0')}';
}

/// Firestore: users/{uid} を読み込み、なければ適当に補完
final memberProfileProvider = FutureProvider<MemberProfile>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('not-logged-in');

  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final data = snap.data() ?? const <String, dynamic>{};

  final displayName = _strOrEmpty(data['displayName'] ?? user.displayName ?? 'ユーザー名');
  final accountId   = _strOrEmpty(data['accountId']);
  final gender      = _strOrEmpty(data['gender']);   // '男性' など
  final country     = _strOrEmpty(data['country']);  // '日本' など
  final postalCode  = _strOrEmpty(data['postalCode']);
  final address1    = _strOrEmpty(data['address1']);
  final address2    = _strOrEmpty(data['address2']);
  final mobilePhone = _strOrEmpty(data['mobilePhone']);
  final landline    = _strOrEmpty(data['landlinePhone']);
  final email       = _strOrEmpty(data['email'] ?? user.email);
  final birthday    = _tsToDate(data['birthday']);

  return MemberProfile(
    displayName: displayName,
    birthday: birthday,
    gender: gender,
    country: country,
    postalCode: postalCode,
    address1: address1,
    address2: address2,
    mobilePhone: mobilePhone,
    landlinePhone: landline,
    email: email,
    accountId: accountId.isEmpty ? null : accountId,
  );
});
