// lib/pages/privacy_page.dart
import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: PrivacyContent(),
      ),
    );
  }
}

class PrivacyContent extends StatelessWidget {
  const PrivacyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '''
Stage＋（ステージプラス）プライバシーポリシー
最終更新日：2025年11月2日

本プライバシーポリシーは、Stage＋（以下「本アプリ」）が提供するサービスにおいて、
ユーザー（以下「会員」）の個人情報をどのように取り扱うかを定めるものです。

────────────────────────────
第1条（収集する情報）
本アプリでは、会員登録やサービス利用に際して、以下の情報を取得する場合があります：
・メールアドレス、パスワード（Firebase Authenticationによる認証）  
・氏名またはニックネーム（任意）  
・ログイン履歴、アクセス履歴、利用状況  
・購入履歴や決済情報（必要な範囲内で）  
・お問い合わせ時の通信内容

────────────────────────────
第2条（利用目的）
取得した情報は、以下の目的で利用します：
・アカウントの作成、本人確認、ログイン管理  
・サービスの提供および品質向上  
・イベント・ニュース等の通知や案内  
・不正利用防止およびセキュリティ対策  
・お問い合わせ対応やサポート運営  
・法令に基づく対応

────────────────────────────
第3条（外部サービスの利用）
本アプリでは、以下の外部サービスを利用しています。  
各サービスのプライバシーポリシーに基づいてデータが取り扱われます。

・Firebase Authentication（Google LLC 提供）  
・Cloud Firestore（Google LLC 提供）  
・Firebase Cloud Messaging（通知配信）  
・Google Analytics for Firebase（利用状況解析）

これらのサービスを通じて収集される情報は匿名化され、個人を特定する目的では利用されません。

────────────────────────────
第4条（個人情報の管理）
運営は、個人情報の漏洩・紛失・改ざんを防止するため、適切なセキュリティ対策を講じます。  
また、利用目的達成後または退会時には、適切な方法でデータを削除または匿名化します。

────────────────────────────
第5条（第三者提供）
運営は、以下の場合を除き、ユーザーの個人情報を第三者に提供しません：
1. 本人の同意がある場合  
2. 法令に基づく開示要請がある場合  
3. 利用目的達成のために必要な業務委託を行う場合（委託先に対して適切な管理を行います）

────────────────────────────
第6条（ユーザーによる情報の管理）
会員は、アプリ内の設定や問い合わせを通じて、以下の対応を行うことができます：
・登録情報の確認・変更  
・退会によるアカウント削除  
・通知設定や配信停止の変更  

────────────────────────────
第7条（Cookie・ログ情報の利用）
本アプリでは、アプリの利用状況を把握するためにCookieやログ情報を使用する場合があります。  
これにより個人を特定する情報は収集されません。

────────────────────────────
第8条（プライバシーポリシーの変更）
本ポリシーの内容は、必要に応じて改訂される場合があります。  
改訂後の内容は、本アプリ上に表示された時点で効力を生じます。

────────────────────────────
第9条（お問い合わせ）
個人情報の取扱いに関するお問い合わせは、アプリ内の「お問い合わせ」ページからご連絡ください。

────────────────────────────
【運営者情報】
Stage＋ 運営チーム  
（本ポリシー・個人情報に関する連絡は「お問い合わせ」ページをご利用ください）

以上
      ''',
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.7,
      ),
    );
  }
}
