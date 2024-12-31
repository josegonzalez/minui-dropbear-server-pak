# trimui-brick-dropbear-server.pak

A TrimUI Brick app wrapping [`dropbear`](https://matt.ucc.asn.au/dropbear/dropbear.html), an ssh server.

## Requirements

- Rust (for building)

## Building

```shell
make build
```

## Installation

1. Mount your TrimUI Brick SD card.
2. Download the latest release from Github. It will be named `SSH.Server.pak.zip`.
3. Copy the zip file to `/Tools/tg3040/SSH Server.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/tg3040/SSH Server.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your TrimUI Brick.

## Usage

> [!NOTE]
> The default credentials are:
>
> - `root:tina`
> - `trimui:trimui`

### daemon-mode

By default, `dropbear` runs as a foreground process, terminating on app exit. To run `dropbear` in daemon mode, create a file named `daemon-mode` in the pak folder. This will turn the app into a toggle for `dropbear`.

### passwordless-root

> [!NOTE]
> TODO: Implement me. We need to somehow generate an empty string for a hash and template out the etc/passwd file before mounting it.

To allow access to the root user without specifying a password, create a file named `passwordless-root` in the pak folder.

### password

> [!NOTE]
> TODO: Implement me. We need to somehow generate a hash for the specified password and template out the etc/passwd file before mounting it.

Creating a file named `password` will result in the contents of that file being used as the password for the `trimui` user. If not specified, the password is set to `trimui`.
