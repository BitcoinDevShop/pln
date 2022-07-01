import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names
const String PLN_GRPC_ENDPOINT = "PLN_GRPC_ENDPOINT";

class PrefsStateNotifier extends StateNotifier<String?> {
  PrefsStateNotifier(this.prefs)
      : super(prefs.get(PLN_GRPC_ENDPOINT) as String?);

//  String _federationCode;
  SharedPreferences prefs;

  /// Updates the value asynchronously.
  Future<void> update(String? value) async {
    if (value != null) {
      await prefs.setString(PLN_GRPC_ENDPOINT, value);
    } else {
      await prefs.remove(PLN_GRPC_ENDPOINT);
    }
    super.state = value;
  }

  /// Do not use the setter for state.
  /// Instead, use `await update(value).`
  @override
  set state(String? value) {
    assert(false,
        "Don't use the setter for state. Instead use `await update(value)`.");
    Future(() async {
      await update(value);
    });
  }
}

StateNotifierProvider<PrefsStateNotifier, String?> createPrefProvider({
  required SharedPreferences Function(Ref) prefs,
}) {
  return StateNotifierProvider<PrefsStateNotifier, String?>(
      (ref) => PrefsStateNotifier(prefs(ref)));
}
