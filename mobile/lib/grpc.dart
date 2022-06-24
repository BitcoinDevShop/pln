import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:pln/main.dart';

final plnClientProvider =
    StateNotifierProvider<PlnClient, ManagerClient?>((ref) {
  return PlnClient(ref);
});

class PlnClient extends StateNotifier<ManagerClient?> {
  PlnClient(this.ref) : super(null);

  final Ref ref;

  Future<void> restartClient() async {
    debugPrint("restarting grpc client");

    try {
      final prefs = ref.read(prefProvider);

      final uri = Uri.parse(prefs ?? "http://localhost:5401");

      // TODO is this all I need from the URI?
      final channel = ClientChannel(uri.host + uri.path,
          port: uri.port,
          options: ChannelOptions(
            credentials: const ChannelCredentials.insecure(),
            codecRegistry:
                CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
          ));
      state = ManagerClient(channel);
    } catch (e) {
      throw ("couldn't connect");
    }
  }

  ManagerClient? get() {
    return state;
  }
}
