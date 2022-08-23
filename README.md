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

## Deployment

- [Docker](#docker)
  - [DigitalOcean](#digitalocean)
- [Source](#source)

### Source

To build from source, download the most recent source code and build it with `cargo`.

```shell
git clone https://github.com/BitcoinDevShop/pln.git
cd pln
cargo build --release
```

The binary is built to `target/release/pln`.

### Docker

There is a Docker container pre-built that can be used to run this instead.

```shell
# pull it!
docker pull ghcr.io/BitcoinDevShop/pln:v0.0.1
```

If you want to build the Docker image locally:

```shell
# build it!
docker build -t bitcoindevshop/pln .
```

```shell
# run it in regtest mode!
docker compose up
```

```shell
# run it in testnet/mainnet mode!
# this requires your own bitcoind instance running somewhere accessible
# replace the values below

docker run -e BITCOIND_RPC_HOST='127.0.0.1' \
-e BITCOIND_RPC_PASSWORD='123' \
-e BITCOIND_RPC_PORT='8443' \
-e BITCOIND_RPC_USERNAME='admin1' \
-e NETWORK='mainnet' \
-e DATA_DIR='/mnt/ln-data' \
-v .local/data:/mnt/ln-data \
bitcoindevshop/pln
```

#### DigitalOcean

You can set up a DigitalOcean instance for about ~$11 with a mainnet integrated prune bitcoind node using our Docker Compose script.

1. Get the one click docker package on Digital Ocean: https://marketplace.digitalocean.com/apps/docker
2. Use the following configurations, at minimum:
	1. Basic CPU
	2. Regular SSD
	3. 2GB / 2 CPU / 50GB storage
3. SSH into the machine when it is ready
4. Pull down the repo:
	1. `git clone https://github.com/BitcoinDevShop/pln.git && cd pln`
6. Run docker compose for mainnet:
	1. `docker-compose -f docker-compose.mainnet-prune.yaml up -d`

## Running Rust backend

```
cargo run  -- --development-mode=true --network=regtest --bitcoind-rpc-host=localhost --bitcoind-rpc-port=18443 --bitcoind-rpc-username=user --bitcoind-rpc-password=pass --data-dir={YOUR_DATA_DIR}
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

### Example Setup / Commands

Sending a regtest bitcoin transaction (when you need to create a channel on Mutiny)

```
bitcoin-cli -named sendtoaddress address="bcrt1qmjwu997paw5pec8kp4t2qzuktw5anqyf39t3xd" amount=0.002 fee_rate=1 replaceable=true
```
