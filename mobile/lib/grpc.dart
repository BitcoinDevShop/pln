import 'package:grpc/grpc.dart';
import 'package:pln/generated/pln.pbgrpc.dart';

final _channel = ClientChannel(
  'localhost',
  port: 5401,
  options: ChannelOptions(
    credentials: const ChannelCredentials.insecure(),
    codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
  ),
);

final plnClient = ManagerClient(_channel);
