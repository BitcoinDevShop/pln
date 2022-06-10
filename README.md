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
pub global activate protoc_plugin
export PATH="$PATH":"$HOME/resources_for_dev/flutter/.pub-cache/bin"
```

```
protoc -I. -I../proto --dart_out=grpc:lib/generated ../proto/pln.proto
```

### Paul's polar setup

cargo run -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=polaruser --bitcoind-rpc-password=polarpass --data-dir=./.data --port-range-min=12000 --port-range-max=12500

bitcoin-cli -named sendtoaddress address="bcrt1qufgnuvauh75unh7at6855ghe7ngdcpmkwtgpjl" amount=0.002 fee_rate=1 replaceable=true

## Todo

- [x] Tony: embedded sensei
- [x] Tony: custom grpc
- [x] Tony: create node if not exists
- [x] Paul: rough figma draft
- [x] Paul: meme
- [x] Paul: make most of the screens
- [x] Paul + Tony: flutter grpc works
- [x] Tony: stub rest of grpc api
- [x] Paul: import rest of grpc api
- [x] Tony: fake logic for grpc api
- [ ] Tony: implement apis
- [ ] API: open_channel
- [ ] API: channel_status
- [ ] API: create_send
- [ ] API: send_status
- [ ] API: get_balance
- [ ] Paul: wire up frontend to logic
- [x] LOGIC: open channel
- [x] LOGIC: poll channel
- [x] LOGIC: create send
- [x] LOGIC: poll send
- [x] LOGIC: poll balance
- [ ] Paul + Tony: make sure everything actually works
- [ ] Paul + Tony: make a presentation

## Stretch Todo

- [ ] Tony: decode invoices
- [ ] Tony: subscribe apis
- [ ] Paul: hook up subscribe apis
- [ ] Tony: update sensei to ldk v107
- [ ] Tony: zero-conf
- [ ] Tony: scid
- [ ] Paul: scan QR to get endpoint for "signup"
- [ ] Tony: Token authscan
- [ ] Paul: Make it prettier
- [ ] Tony: multi-node payments (virtual channels?)

## Paul mini todo

another lightning node on nigiri
get its connection string
paste connection string in create channel
use nigiri to send money to bitcoin address in fund channel
it should create the channel
