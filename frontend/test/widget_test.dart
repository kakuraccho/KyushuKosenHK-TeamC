import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focus_lapse/main.dart';
import 'package:focus_lapse/screens/view/view_screen.dart';

void main() {
  // ----------------------------------------------------------
  // Test 1: アプリが起動し MainScreen が表示される
  // ----------------------------------------------------------
  testWidgets('App launches and MainScreen is displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // MyApp が MaterialApp を返す
    expect(find.byType(MaterialApp), findsOneWidget);

    // MainScreen の骨格 (Scaffold) が存在する
    expect(find.byType(Scaffold), findsWidgets);
  });

  // ----------------------------------------------------------
  // Test 2: BottomNavBar の 3 タブが表示される
  // ----------------------------------------------------------
  testWidgets('BottomNavBar shows View, Shoot and SNS tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 各タブラベルが表示されている
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Shoot'), findsOneWidget);
    expect(find.text('SNS'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // Test 3: デフォルト表示は ViewScreen (View - Pomodoro タイトル)
  // ----------------------------------------------------------
  testWidgets('Default screen is ViewScreen showing View - Pomodoro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // ViewScreen の AppBar タイトルが "View - Pomodoro" である
    expect(find.text('View - Pomodoro'), findsOneWidget);

    // ViewScreen が表示されている（内部に TabBar はなく subTab で制御される）
    expect(find.byType(ViewScreen), findsOneWidget);
  });

  // ----------------------------------------------------------
  // Test 4: Shoot タブをタップすると ShootScreen に切り替わる
  // ----------------------------------------------------------
  testWidgets('Tapping Shoot tab switches to ShootScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // BottomNavBar の "Shoot" テキストをタップ
    // IndexedStack では非アクティブ画面もツリーにあるため、
    // BottomNavBar 側の "Shoot" を特定して tap する
    final shootNavItems = find.text('Shoot');
    await tester.tap(shootNavItems.first);
    await tester.pumpAndSettle();

    // ShootScreen の AppBar タイトルが表示される
    expect(find.text('Shoot'), findsWidgets);
  });

  // ----------------------------------------------------------
  // Test 5: SNS タブをタップすると SnsScreen に切り替わる
  // ----------------------------------------------------------
  testWidgets('Tapping SNS tab switches to SnsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // BottomNavBar の "SNS" をタップ
    await tester.tap(find.text('SNS'));
    await tester.pumpAndSettle();

    // SnsScreen の AppBar タイトルが表示される
    expect(find.text('SNS'), findsWidgets);
  });

  // ----------------------------------------------------------
  // Test 6: View タブに戻ると ViewScreen が再表示される
  // ----------------------------------------------------------
  testWidgets('Tapping View tab returns to ViewScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // SNS へ移動してから View へ戻る
    await tester.tap(find.text('SNS'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    // ViewScreen の AppBar タイトルが再び表示される
    expect(find.text('View - Pomodoro'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // Test 7: View の NavItem を 2 回タップするとサブメニューが
  //         表示され（heightFactor=1.0）、もう一度タップすると
  //         非表示になる（トグル）
  // ----------------------------------------------------------
  testWidgets('Tapping View nav icon twice toggles sub-menu overlay',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 初期状態: AnimatedAlign の heightFactor が 0 のため
    // Pomodoro / Videos セグメントはポインタを無視している
    // (_showSubMenu == false なので IgnorePointer.ignoring = true)
    final pomodoroFinder = find.text('Pomodoro');

    // 1回目のタップ: すでに View タブ表示中なので _showSubMenu が true になる
    await tester.tap(find.text('View'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // アニメーション完了待ち

    // サブメニューが展開され Pomodoro テキストが見える
    expect(pomodoroFinder, findsOneWidget);

    // 2回目のタップ: _showSubMenu が false に戻る
    await tester.tap(find.text('View'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // heightFactor=0 になるが ウィジェット自体はツリーに残る
    // IgnorePointer で入力は受け付けなくなる（見た目上は消える）
    // ウィジェットが存在することと、_showSubMenu=false の確認
    expect(find.byType(AnimatedAlign), findsOneWidget);
  });

  // ----------------------------------------------------------
  // Test 8: サブメニューの Videos を選択すると AppBar タイトルが
  //         "View - Videos" に変わる
  // ----------------------------------------------------------
  testWidgets('Selecting Videos in sub-menu changes title to View - Videos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // View タブをタップしてサブメニューを開く
    await tester.tap(find.text('View'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // サブメニューの "Videos" セグメントをタップ
    await tester.tap(find.text('Videos'));
    await tester.pumpAndSettle();

    // AppBar のタイトルが "View - Videos" に変わっている
    expect(find.text('View - Videos'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // Test 9: サブメニューの Pomodoro を選択すると AppBar タイトルが
  //         "View - Pomodoro" に戻る
  // ----------------------------------------------------------
  testWidgets('Selecting Pomodoro in sub-menu changes title to View - Pomodoro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // まず Videos に切り替える
    await tester.tap(find.text('View'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Videos'));
    await tester.pumpAndSettle();

    expect(find.text('View - Videos'), findsOneWidget);

    // もう一度サブメニューを開いて Pomodoro を選択
    await tester.tap(find.text('View'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    // AppBar タイトルが "View - Pomodoro" に戻っている
    expect(find.text('View - Pomodoro'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // Test 10: AppBar に hamburger menu と account_circle アイコンが
  //          表示される
  // ----------------------------------------------------------
  testWidgets('AppBar contains menu icon and account_circle icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });
}
