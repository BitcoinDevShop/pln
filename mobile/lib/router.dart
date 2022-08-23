import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mutiny/main.dart';
import 'package:mutiny/screens/channel_status.dart';
import 'package:mutiny/screens/error_page.dart';
import 'package:mutiny/screens/welcome.dart';

import 'screens/deposit.dart';
import 'screens/channel_fund.dart';
import 'screens/home.dart';
import 'screens/receive.dart';
import 'screens/send.dart';
import 'screens/send_confirm.dart';
import 'screens/send_status.dart';

/// Caches and Exposes a [GoRouter]
final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: true, // For demo purposes
    refreshListenable: router, // This notifiies `GoRouter` for refresh events
    redirect: router._redirectLogic, // All the logic is centralized here
    routes: router._routes, // All the routes can be found there
    errorBuilder: (context, state) => ErrorPage(errorReason: state.error),
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  /// This implementation exploits `ref.listen()` to add a simple callback that
  /// calls `notifyListeners()` whenever there's change onto a desider provider.
  RouterNotifier(this._ref) {
    _ref.listen<String?>(
      prefProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? _redirectLogic(GoRouterState state) {
    return null;
  }

  List<GoRoute> get _routes => [
        GoRoute(
            path: "/errormodal",
            pageBuilder: (context, state) {
              return MaterialPage(
                  fullscreenDialog: true,
                  child: ErrorPage(errorMessage: state.extra.toString()));
            }),
        GoRoute(path: "/welcome", builder: (context, state) => const Welcome()),
        GoRoute(path: "/", builder: (context, state) => const Home(), routes: [
          GoRoute(
              path: "send",
              builder: (context, state) => const SendScreen(),
              routes: [
                GoRoute(
                    path: "confirm",
                    builder: (context, state) => const SendConfirm()),
                GoRoute(
                    path: "status",
                    builder: (context, state) => const SendStatus()),
              ]),
          GoRoute(
              path: "receive", builder: (context, state) => const Receive()),
          GoRoute(
              path: "channel",
              builder: (context, state) => const DepositScreen(),
              routes: [
                GoRoute(
                    path: "fund",
                    builder: (context, state) => const ChannelFund()),
                GoRoute(
                    path: "status",
                    builder: (context, state) => const ChannelStatus())
              ])
        ]),
      ];
}
