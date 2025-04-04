# minui-dropbear-server.pak

A MinUI app wrapping [`dropbear`](https://matt.ucc.asn.au/dropbear/dropbear.html), an ssh server.

## Requirements

This pak is designed and tested on the following MinUI Platforms and devices:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro
- `rg35xxplus`: RG-35XX Plus, RG-34XX, RG-35XX H, RG-35XX SP

Use the correct platform for your device.

## Installation

1. Mount your MinUI SD card.
2. Download the latest release from Github. It will be named `SSH.Server.pak.zip`.
3. Copy the zip file to `/Tools/$PLATFORM/SSH Server.pak.zip`. Please ensure the new zip file name is `SSH Server.pak.zip`, without a dot (`.`) between the words `SSH` and `Server`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/$PLATFORM/SSH Server.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your MinUI device.

## Usage

> [!IMPORTANT]
> If the zip file was not extracted correctly, the pak may show up under `Tools > SSH`. Rename the folder to `SSH Server.pak` to fix this.

Browse to `Tools > SSH Server` and press `A` to turn on the SSH server.

This pak runs on port `22` (SSH).

The default credentials are:

- `root:tina`
- `trimui:trimui`

### Debug Logging

Debug logs are written to the`$SDCARD_PATH/.userdata/$PLATFORM/logs/` folder.

### Configuration

#### passwordless-root

> [!NOTE]
> TODO: Implement me. We need to somehow generate an empty string for a hash and template out the etc/passwd file before mounting it.

To allow access to the root user without specifying a password, create a file named `passwordless-root` in the `$SDCARD_PATH/.userdata/$PLATFORM/SSH Server` folder.

#### password

> [!NOTE]
> TODO: Implement me. We need to somehow generate a hash for the specified password and template out the etc/passwd file before mounting it.

Creating a file named `password` in the `$SDCARD_PATH/.userdata/$PLATFORM/SSH Server` folder will result in the contents of that file being used as the password for the `trimui` user. If not specified, the password is set to `trimui`.
