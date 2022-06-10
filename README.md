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

## nigiri commands

```
nigiri start --ln

nigiri rpc getnewaddress "" "bech32"
nigiri rpc generatetoaddress 10 "<address_from_previous_command>"
```

lnd ipub:
03078bab52f9c327303ff26f5e48aab404ebe5bef247285c1d47ded1c2c844b2fa@localhost:9735

nigiri rpc sendtoaddress address="bcrt1ql07aqt5mrjete9h0ds3vzeywh7ax0n6lnu4x4k" amount=0.001 fee_rate=1 replaceable=true

nigri rpc -named sendtoaddress address="bcrt1qh28qv30xqhqnguuqdm93huk9uvpt3xz3am8u2r" amount=0.001 fee_rate=1 replaceable=true

nigiri rpc sendtoaddress

nigiri rpc -sendtoaddress "bcrt1ql07aqt5mrjete9h0ds3vzeywh7ax0n6lnu4x4k" "0.002" 1 true

nigiri rpc sendtoaddress { address: "bcrt1ql07aqt5mrjete9h0ds3vzeywh7ax0n6lnu4x4k", amount: 0.001, fee_rate: 1, eplaceable: true}

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
