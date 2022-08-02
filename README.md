# pLN - privacy is the only option

- Spin up a new node for every channel open
- Fund channels with an external wallet, and no change!
- Sending
- No receive lol
- DO NOT USE THIS ISN'T EVEN ALPHA YET

Here's our hackathon presentation: [slides](https://github.com/BitcoinDevShop/pln/files/8893172/pln.pdf) and [video](https://www.youtube.com/watch?v=gaQ0m1AMpq0?start=6454)

## Architecture

<img width="393" alt="Screen Shot 2022-06-13 at 10 11 12 AM" src="https://user-images.githubusercontent.com/543668/173408578-6b0e9f41-6ea6-4f28-aa91-7f1d9a565357.png">

## How Channel Opens Work

<img width="702" alt="Screen Shot 2022-06-13 at 10 12 12 AM" src="https://user-images.githubusercontent.com/543668/173408613-aebf32e3-d751-4c50-80c9-1125b1fc61ec.png">

## Running Rust backend

Tony

```
cargo run  -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=user --bitcoind-rpc-password=pass --data-dir={YOUR_DATA_DIR}
```

Paul

```
cargo run  -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=polaruser --bitcoind-rpc-password=polarpass --data-dir=./.data
```

The GRPC should run on `5401`

## Running Flutter frontend

[Install Flutter](https://docs.flutter.dev/get-started/install) for your dev OS and chosen target.

`flutter doctor` will let you know how your setup is looking.

Follow the relevant instructions for running a Flutter app from your IDE (this is nice because you get better debugging and hot reload).

If you want to run from the terminal, enter the `/mobile` dir and run one of these:
`flutter run -d macos` for Mac
`flutter run -d linux` for Linux
`flutter run -d <device id>` for an iOS or Android simulator (list available simulators via `flutter devices`)

## regen protobuf stuff for flutter:

(from mobile dir):

```
flutter pub global activate protoc_plugin
export PATH="$PATH":"$HOME/resources_for_dev/flutter/.pub-cache/bin"
protoc -I. -I../proto --dart_out=grpc:lib/generated ../proto/pln.proto
```

### Paul's polar setup

cargo run -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=polaruser --bitcoind-rpc-password=polarpass --data-dir=./.data --port-range-min=12000 --port-range-max=12500

bitcoin-cli -named sendtoaddress address="bcrt1qmjwu997paw5pec8kp4t2qzuktw5anqyf39t3xd" amount=0.002 fee_rate=1 replaceable=true

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
- [x] Tony: implement apis
- [x] API: open_channel
- [x] API: channel_status
- [x] API: create_send
- [x] API: send_status
- [x] API: get_balance
- [x] Paul: wire up frontend to logic
- [x] LOGIC: open channel
- [x] LOGIC: poll channel
- [x] LOGIC: create send
- [x] LOGIC: poll send
- [x] LOGIC: poll balance
- [ ] Paul + Tony: make sure everything actually works
- [x] Paul + Tony: make a presentation

## Stretch Todo

- [x] Paul: decode invoices
- [ ] Tony: subscribe apis
- [ ] Paul: hook up subscribe apis
- [ ] Tony: update sensei to ldk v107
- [ ] Tony: zero-conf
- [ ] Tony: scid
- [ ] Paul: scan QR to get endpoint for "signup"
- [ ] Tony: Token authscan
- [ ] Paul: Make it prettier
- [ ] Tony: multi-node payments (virtual channels?)
