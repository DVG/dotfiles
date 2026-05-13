# Context

Arguments: $ARGUMENTS

The user wants to clip a portion of a video file using plain language to describe the time range.

## Your Task

Parse `Arguments` into:
- **File** — a file path (required). If missing, say "Usage: `/video:clip <file> <plain language time description>`" and stop.
- **Time description** — everything after the file path, in plain language (required). If missing, say "Usage: `/video:clip <file> <plain language time description>`" and stop.

### 1. Interpret the time description

Convert the plain language time description into two numeric values in **seconds**:
- **start** — where to begin the clip (default: `0`)
- **duration** — how long the clip should be

Handle natural phrasing like:
- "the first 43 seconds" → start=0, duration=43
- "start at 1:30 and go to 2:30" → start=90, duration=60
- "from 0:45 to 1:15" → start=45, duration=30
- "last 20 seconds" → requires knowing the video length first (see below)
- "30 seconds starting at 5 minutes" → start=300, duration=30
- "the first minute" → start=0, duration=60
- "2:00 to the end" → requires knowing the video length first (see below)

When converting timestamps like `1:30`, treat them as `minutes:seconds` (= 90 seconds). For `1:30:00`, treat as `hours:minutes:seconds`.

**If the description references the end of the video** (e.g., "last 20 seconds", "3:00 to the end"), first get the video duration by running:

```
ffprobe -v error -show_entries format=duration -of csv=p=0 "<file>"
```

Then calculate start/duration accordingly.

### 2. Build an output filename

Take the input filename and append `_clip` before the extension. For example: `interview.mp4` becomes `interview_clip.mp4`. If that file already exists, append a number (e.g., `interview_clip-2.mp4`).

### 3. Run the clip command

Run:

```
run video clip "<file>" -s <start> -d <duration> -o "<output_file>"
```

Where `-s` is the start time in seconds and `-d` is the duration in seconds.

### 4. Report the result

Tell the user the final output path, the time range extracted (in human-readable form like `0:45–1:15`), and the duration.

## Rules

- Never add `Co-Authored-By` or any AI attribution lines
- If the file doesn't exist, report the error and stop
- If the clip command fails, report the error and stop
- Always quote filenames in commands
- All time values passed to the CLI must be in seconds (integers)
