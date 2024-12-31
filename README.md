# trimui-brick-dropbear-server.pak

A TrimUI Brick app wrapping [`dropbear`](https://matt.ucc.asn.au/dropbear/dropbear.html), an ssh server.

## Requirements

- Rust (for building)

## Building

```shell
make build
```

## Installation

> [!IMPORTANT]
> The dropbear binary **must** first be built for the TrimUI Brick.

1. Mount your TrimUI Brick SD card.
2. Create a folder in your SD card with the full-path of `/Tools/tg3040/Toggle SSH Server.pak`.
3. Copy `launch.sh`, `bin` and `res` to that SD card folder, ensuring it is still executable.
4. Unmount your SD Card and insert it into your TrimUI Brick.

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
