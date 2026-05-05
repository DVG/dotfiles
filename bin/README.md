# Run CLI

A powerful command-line interface for managing development workflows, project configurations, and common tasks.

## Overview

`run` is a Thor-based CLI tool that provides:
- Project-aware command execution (test, build, deploy, etc.)
- Git worktree management for AI agent workflows
- Video/audio conversion and editing
- Database access token generation
- YouTube video downloading
- Git workflow shortcuts

## Installation

The `run` binary should be in your PATH. It uses inline gemfile bundling, so it will automatically install dependencies on first run.

Required system dependencies:
```bash
# Install via Homebrew bundle
run bundle
```

## Global Options

- `-v, --verbose` - Show detailed output
- `--dry-run` - Show what commands would run without executing them

## Core Commands

### Project Management

#### `run install`
Install dependencies for the current project (auto-detects project type).

#### `run start [OPTIONS]`
Start the development server.
- `--port PORT` - Specify port number
- `--env ENV` - Environment to run in (default: development)

#### `run test [FILES...]`
Run tests, optionally on specific files.
```bash
run test                           # Run all tests
run test spec/models/user_spec.rb  # Run specific test
run test "spec/models/**/*"        # Run tests matching pattern
```

#### `run lint [FILES...] [OPTIONS]`
Run linters on code.
- `--fix` - Auto-fix issues where possible
```bash
run lint                  # Lint all files
run lint src/            # Lint specific directory
run lint --fix           # Auto-fix issues
```

#### `run build [OPTIONS]`
Build the application.
- `--env ENV` - Build environment (default: production)

#### `run deploy [OPTIONS]`
Deploy the application.
- `--env ENV` - Deployment environment (default: staging)
- `--confirm` - Skip confirmation prompt

#### `run logs [FILES...]`
Tail application logs.
- `--follow` - Follow log output (default: true)
- `--lines N` - Number of lines to show (default: 100)

#### `run open`
Open the local development server in your browser (requires port configuration).

### Configuration Commands

#### `run setup [PROJECT_NAME]`
Initialize configuration for the current repository.
- `--name NAME` - Override project name

Creates a YAML config file in `~/.dotfiles/run/projects/`

#### `run config [PROJECT_NAME]`
Show configuration for current or specified project.

#### `run edit [PROJECT_NAME]`
Edit configuration file for current or specified project in `$EDITOR`.

#### `run list`
List all configured projects.

#### `run status [PROJECT_NAME]`
Show repository status and available commands.

#### `run debug COMMAND [ARGS...]`
Debug command execution (shows what would be run).

### System Commands

#### `run bundle [OPTIONS]`
Install system dependencies from Brewfile in your dotfiles.
- `--check` - Check if dependencies are installed
- `--cleanup` - Remove formulae not in Brewfile

#### `run version`
Show version information.

## Subcommands

### YouTube Commands (`run yt`)

#### `run yt download VIDEO_URL [OPTIONS]`
Download a YouTube video using yt-dlp.
- `-o, --output TEMPLATE` - Output file template (default: `%(title)s.%(ext)s`)

```bash
run yt download "https://www.youtube.com/watch?v=..."
run yt download "https://www.youtube.com/watch?v=..." -o "my-video.mp4"
```

### Git Agent Worktree Commands (`run agent`)

Manage git worktrees for parallel development workflows (useful for AI agents).

#### `run agent create TOPIC [OPTIONS]`
Create a new git worktree for a topic.
- `--from-branch BRANCH` - Base branch to create from
- `--branch NAME` - Name for the new branch

```bash
run agent create feature-auth                    # Create from default branch
run agent create bugfix --from-branch develop    # Create from specific branch
```

#### `run agent destroy TOPIC [OPTIONS]`
Delete a worktree.
- `-f, --force` - Force deletion with uncommitted changes
- `--delete-branch` - Also delete the associated branch

```bash
run agent destroy feature-auth
run agent destroy feature-auth --delete-branch
```

#### `run agent list`
List all worktrees.

#### `run agent status TOPIC`
Show git status of a specific worktree.

#### `run agent open TOPIC`
Open a worktree directory in your editor.

### Database Commands (`run db`)

#### `run db password ENV`
Generate AWS RDS auth token and copy to clipboard.
- `ENV` - Environment: `stage` or `prod`

```bash
run db password stage
```

### Git Helper Commands (`run git`)

#### `run git amend`
Amend the last commit with current changes (keeps same message).

#### `run git undo`
Undo the last commit but keep changes staged.

#### `run git fuck-it`
Commit everything with "fuck it" message and push.

#### `run git ignore FILE_OR_PATTERN`
Add a file or pattern to .gitignore.

```bash
run git ignore "*.log"
run git ignore .env.local
```

#### `run git nuke BRANCH [OPTIONS]`
Delete a branch locally and remotely.
- `-f, --force` - Force delete

```bash
run git nuke old-feature
run git nuke old-feature --force
```

#### `run git stop FILE`
Remove a file from git tracking without deleting it.

#### `run git touch`
Create an empty commit.

#### `run git edit-message`
Edit the last commit message.

#### `run git branch copy`
Copy the current branch name to clipboard.

### Conversion Commands (`run convert`)

#### `run convert video INPUT_FILE -f FORMAT [OPTIONS]`
Convert video to different formats.
- `-f, --format FORMAT` - Output format (mp3, mp4, wav, webm, etc.)
- `-o, --output PATH` - Output file path

```bash
run convert video input.webm -f mp3
run convert video video.mp4 -f wav -o audio.wav
```

### Video Editing Commands (`run video`)

#### `run video clip INPUT_FILE [OPTIONS]`
Extract a clip from a video.
- `-d, --duration N` - Duration in seconds (default: 60)
- `-s, --start N` - Start time in seconds (default: 0)
- `-o, --output PATH` - Output file path

```bash
run video clip input.mp4                          # Extract first 60 seconds
run video clip input.mp4 -d 30                    # Extract first 30 seconds
run video clip input.mp4 -s 10 -d 45              # Extract 45s starting at 10s
run video clip input.mp4 -s 120 -d 30 -o clip.mp4 # Custom output name
```

## Configuration

Project configurations are stored in `~/.dotfiles/run/projects/PROJECT_NAME.yml`.

### Example Project Config

```yaml
name: my-app
type: node
commands:
  install: npm install
  start: npm start
  test: npm test -- {{args}}
  lint: npm run lint -- {{fix}} {{args}}
  build: npm run build
  logs: tail -f logs/development.log {{args}}
  deploy: npm run deploy
health_check:
  url: http://localhost:3000/health
  timeout: 30
environment:
  development:
    port: 3000
  staging:
    url: https://my-app-staging.example.com
  production:
    url: https://my-app.example.com
worktree_dir: ~/worktrees/my-app
default_branch: main
env_file: .env
```

### Variable Substitution

Commands support the following placeholders:
- `{{args}}` - Replaced with command arguments
- `{{fix}}` - Replaced with auto-fix flag for linters
- `{{port}}` - Replaced with port number
- `{{env}}` - Replaced with environment name

## Project Type Detection

`run` automatically detects project type based on:
- `Gemfile` or `config/application.rb` → Ruby
- `package.json` → Node.js
- `requirements.txt` or `pyproject.toml` → Python
- `go.mod` → Go

## Tips

### Quick Setup
```bash
cd ~/projects/my-app
run setup
run edit  # Customize commands
```

### Test Workflow
```bash
run test                           # Run all tests
run test spec/models              # Test specific directory
run test --verbose                # Show detailed output
```

### Worktree Workflow
```bash
run agent create new-feature      # Create worktree
cd ~/worktrees/my-app/new-feature # Work on feature
run agent status new-feature      # Check status
run agent destroy new-feature     # Clean up when done
```

### Media Processing
```bash
# Download and convert YouTube video to MP3
run yt download "URL" -o "song.%(ext)s"
run convert video song.webm -f mp3

# Extract a 30-second clip from a video
run video clip movie.mp4 -s 60 -d 30 -o highlight.mp4
```

## Dependencies

- Ruby (with bundler/inline support)
- ffmpeg (for media commands)
- yt-dlp (for YouTube downloads)
- git (for worktree and git commands)

Install system dependencies:
```bash
run bundle
```

## Environment Variables

- `DOTFILES_DIR` - Override dotfiles directory (default: `~/.dotfiles`)
- `EDITOR` - Your preferred editor (default: `vim`)

## Troubleshooting

### Commands not found
```bash
run status  # Check if project is configured
run setup   # Initialize project config
```

### Verbose output
```bash
run --verbose test  # See exactly what commands are running
```

### Debug mode
```bash
run debug test spec/models  # See what would run without executing
```

## License

Personal dotfiles - use as you wish.
