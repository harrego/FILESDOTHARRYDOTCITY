# FILESDOTHARRYDOTCITY

Temporary file sharing

## CLI upload tool

Move `hdc.sh` to `/usr/local/bin/hdc` and `chmod +x /usr/local/bin/hdc`.

### Help output

```
FILESDOTHARRYDOTCITY upload tool v1.0 - upload temporary files to files.harry.city

usage: hdc [--version] [--help] [-p <password> | --password <password>] [-u <url> | --url <url>] [-x] [-c | --clip] <file path>

options:
  <file path> | clipboard
      If no file path is provided then the image in the clipboard will be used.

  --version
      Prints the tool version.

  --help
      Prints description and tool arguments.

  -p <password>, --password <password>
      Password for the server. Can also be provided at the top of the script.

  -u <url>, --url <url>
      Uses a different upload URL than the one embedded in the tool. Can be used for debugging purposes.

  -x
      Generates a URL using the 'x' id scheme.

  -c, --clip
      Upload an image clip (uses xclip and maim on Linux).
```

## Wiping cron command

`0 * * * * find $LOCATION/static -type f -mmin +1440 -delete`