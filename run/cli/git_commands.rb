class BranchCommands < Thor
  include SystemCommandable

  desc 'copy', 'Copy the current branch name to clipboard'
  def copy
    branch_name = `git branch --show-current`.strip

    if branch_name.empty?
      puts "Error: Not on a git branch".colorize(:red)
      exit(1)
    end

    # Copy to clipboard (macOS)
    IO.popen('pbcopy', 'w') { |pipe| pipe.puts branch_name }
    puts "Copied branch name to clipboard: #{branch_name}".colorize(:green)
  end
end

class GitCommands < Thor
  include SystemCommandable

  desc 'branch SUBCOMMAND', 'Git branch operations'
  subcommand 'branch', BranchCommands

  desc 'amend', 'Use the last commit message and amend your changes'
  def amend
    execute_command('git commit --amend -C HEAD', 'Amending commit...')
  end

  desc 'undo', 'Undo your last commit, but keep your changes'
  def undo
    execute_command('git reset --soft HEAD^', 'Undoing last commit...')
  end

  desc 'fuck-it', 'Commit everything with "fuck it" message'
  def fuck_it
    commands = [
      'git add .',
      'git commit -m "fuck it"',
      'git push'
    ]
    execute_command(commands.join(' && '), 'Committing and pushing...')
  end

  desc 'ignore FILE_OR_PATTERN', 'Add a file or pattern to .gitignore'
  def ignore(pattern)
    File.open('.gitignore', 'a') do |f|
      f.puts pattern
    end
    puts "Added '#{pattern}' to .gitignore".colorize(:green)
  end

  desc 'nuke [BRANCH]', 'Delete a branch locally and remotely'
  option :force, aliases: '-f', type: :boolean, desc: 'Force delete'
  def nuke(branch = nil)
    unless branch
      puts "Error: Please specify a branch to delete".colorize(:red)
      exit(1)
    end

    current_branch = `git branch --show-current`.strip
    if current_branch == branch
      puts "Error: Cannot delete the current branch. Switch to another branch first.".colorize(:red)
      exit(1)
    end

    force_flag = options[:force] ? '-D' : '-d'
    commands = [
      "git branch #{force_flag} #{branch}",
      "git push origin --delete #{branch} 2>/dev/null || true"
    ]
    execute_command(commands.join(' && '), "Deleting branch #{branch}...")
  end

  desc 'stop', 'Remove a file from git without deleting it'
  def stop(file)
    execute_command("git rm --cached \"#{file}\"", "Removing #{file} from git...")
  end

  desc 'touch', 'Create an empty commit'
  def touch
    execute_command('git commit --allow-empty -m "Empty commit"', 'Creating empty commit...')
  end

  desc 'edit-message', 'Edit the last commit message'
  def edit_message
    execute_command('git commit --amend', 'Editing commit message...')
  end
end
