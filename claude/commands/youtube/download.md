# Context

Arguments: $ARGUMENTS

The user wants to download a YouTube video, convert it to a clean format, and give it a friendly filename.

## Your Task

Parse `Arguments` into:
- **URL** — the first argument (required). If missing, say "Usage: `/youtube:download <URL> [format]`" and stop.
- **Format** — the second argument (optional, default: `mp4`)

Then follow these steps:

### 1. Download the video

Run:

```
run yt download <URL>
```

This uses yt-dlp and saves a file named `<video title>.<ext>` (usually `.webm` or `.mkv`) in the current directory.

Capture the output to identify the downloaded filename. Look for yt-dlp's `[download] Destination:` or `[Merger] Merging formats into` lines to determine the exact file path. If those aren't present, look for `has already been downloaded` or list files in the current directory to find the new file.

### 2. Generate a friendly filename

Take the raw video title (from the downloaded filename, without extension) and clean it up:

- Remove bracketed/parenthesized metadata like `[Official Video]`, `(4K)`, `(Lyrics)`, `[HD]`, `(Official Music Video)`, `(Audio)`, etc.
- Remove leading/trailing channel names or separators like `Artist -` or `- Topic`
- Strip special characters except hyphens and spaces
- Collapse multiple spaces/hyphens into single ones
- Trim leading/trailing whitespace and hyphens
- Convert to lowercase kebab-case (spaces become hyphens)
- Keep it concise but recognizable

Example: `Rick Astley - Never Gonna Give You Up (Official Music Video) [4K].webm` becomes `never-gonna-give-you-up`

### 3. Convert to the target format

Run:

```
run convert video "<downloaded_file>" -f <format> -o "<friendly_name>.<format>"
```

### 4. Clean up

Delete the intermediate downloaded file (the original webm/mkv) since the conversion is complete.

### 5. Report the result

Tell the user the final output path and format.

## Rules

- Never add `Co-Authored-By` or any AI attribution lines
- If the download fails, report the error and stop — do not proceed to conversion
- If the conversion fails, keep the original downloaded file and report the error
- If a file with the friendly name already exists, append a number (e.g., `never-gonna-give-you-up-2.mp4`)
- Quote all filenames in commands to handle spaces and special characters
