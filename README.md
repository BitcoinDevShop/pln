# pLN

## Running

Tony

```
cargo run  -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=user --bitcoind-rpc-password=pass --data-dir={YOUR_DATA_DIR}
```

Paul

```
cargo run  -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=admin1 --bitcoind-rpc-password=123 --data-dir=./.data
```

The GRPC should run on `5401`, but maybe 3001 lol

## regen protobuf stuff for flutter:

(from mobile dir):

```
protoc -I. -I../proto --dart_out=grpc:lib/generated ../proto/pln.proto
```
