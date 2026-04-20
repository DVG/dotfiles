# Run CLI - Audio Commands

Audio file management commands for the run CLI.

## Audio Art Commands

Add or remove album art from MP3 files with wildcard support.

### Add Album Art

```bash
# Add album art to a single file
run audio art add cover.jpg song.mp3

# Add album art to multiple files using wildcards
run audio art add cover.jpg "*.mp3"
run audio art add cover.jpg "album/*.mp3"

# Save to a different directory (keeps originals)
run audio art add cover.jpg "*.mp3" -o output/

# Create backups before modifying
run audio art add cover.jpg "*.mp3" --backup
```

### Remove Album Art

```bash
# Remove album art from a single file
run audio art remove song.mp3

# Remove album art from multiple files
run audio art remove "*.mp3"

# Save to output directory
run audio art remove "*.mp3" -o cleaned/

# Create backups
run audio art remove "*.mp3" --backup
```

## Audio Info Commands

View metadata and album art information for MP3 files.

### List Files

```bash
# List all MP3 files with metadata in table format
run audio info list "*.mp3"

# List in JSON format
run audio info list "*.mp3" --format json
```

### Show Detailed Info

```bash
# Show detailed metadata for a single file
run audio info show song.mp3

# Show in JSON format
run audio info show song.mp3 --format json
```

## Requirements

- `ffmpeg` and `ffprobe` must be installed
- Install via: `brew install ffmpeg`

## Options

- `-v, --verbose` - Show detailed command output
- `-o, --output-dir DIR` - Save processed files to directory
- `-b, --backup` - Create .bak files before modifying
- `-f, --format FORMAT` - Output format (table/json/pretty)

## Examples

### Batch add album art to an entire album

```bash
# Add the same cover to all tracks in a directory
run audio art add album-cover.jpg "album/*.mp3"
```

### Clean up files without album art

```bash
# First, check which files have album art
run audio info list "*.mp3"

# Remove album art from all files
run audio art remove "*.mp3" --backup
```

### Extract metadata for cataloging

```bash
# Export all metadata as JSON
run audio info list "music/**/*.mp3" --format json > catalog.json
```
