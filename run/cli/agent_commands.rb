# agent_commands.rb
# Git worktree management commands for AI agent workflows

class AgentCommands < Thor
  include Thor::Actions
  include SystemCommandable

  class_option :verbose, type: :boolean, aliases: '-v', desc: 'Verbose output'
  class_option :dry_run, type: :boolean, desc: 'Show commands without executing'

  def initialize(*args)
    super
    @project_name = detect_project_name
    @repo_config = load_repo_config
    @worktree_dir = get_worktree_dir
  end

  desc 'create TOPIC', 'Create a new git worktree for the given topic'
  option :from_branch, type: :string, desc: 'Base branch to create from'
  option :branch, type: :string, desc: 'Name for the new branch'
  def create(topic)
    unless git_repository?
      puts "Error: Not a git repository".colorize(:red)
      exit(1)
    end

    from_branch = options[:from_branch] || get_default_branch
    new_branch = options[:branch] || topic
    worktree_path = File.join(@worktree_dir, topic)

    if Dir.exist?(worktree_path)
      puts "Error: Worktree already exists at #{worktree_path}".colorize(:red)
      exit(1)
    end

    puts "Fetching latest changes...".colorize(:blue)
    run_command("git fetch origin #{from_branch}", quiet: !options[:verbose])

    branch_exists = system("git show-ref --verify --quiet refs/heads/#{new_branch}")

    if branch_exists
      puts "Branch '#{new_branch}' already exists.".colorize(:yellow)
      use_existing = yes?("Use existing branch? (y/N)".colorize(:yellow))

      if use_existing
        create_worktree_from_existing(topic, new_branch, worktree_path)
      else
        puts "Aborted.".colorize(:red)
        exit(1)
      end
    else
      create_worktree_new_branch(topic, from_branch, new_branch, worktree_path)
    end

    display_worktree_info(topic, worktree_path, new_branch)
  end

  desc 'destroy TOPIC', 'Delete the worktree for the given topic'
  option :force, type: :boolean, aliases: '-f', desc: 'Force deletion even with uncommitted changes'
  option :delete_branch, type: :boolean, desc: 'Also delete the associated branch'
  def destroy(topic)
    worktree_path = File.join(@worktree_dir, topic)

    unless Dir.exist?(worktree_path)
      puts "Error: Worktree does not exist at #{worktree_path}".colorize(:red)

      if worktree_registered?(worktree_path)
        puts "Worktree is registered but directory is missing. Cleaning up...".colorize(:yellow)
        run_command("git worktree prune")
        puts "Cleaned up stale worktree references".colorize(:green)
      end

      exit(1)
    end

    branch_name = get_worktree_branch(worktree_path)

    unless options[:force]
      if has_uncommitted_changes?(worktree_path)
        puts "Warning: Worktree has uncommitted changes".colorize(:yellow)
        return unless yes?("Continue with deletion? (y/N)".colorize(:yellow))
      end
    end

    unless options[:force]
      puts "About to delete worktree: #{worktree_path}".colorize(:yellow)
      puts "Branch: #{branch_name}".colorize(:yellow) if branch_name
      return unless yes?("Are you sure? (y/N)".colorize(:yellow))
    end

    if options[:dry_run]
      puts "Would execute: git worktree remove #{worktree_path}".colorize(:blue)
      if options[:delete_branch] && branch_name
        puts "Would execute: git branch -D #{branch_name}".colorize(:blue)
      end
      return
    end

    puts "Removing worktree...".colorize(:blue)
    force_flag = options[:force] ? '--force' : ''
    success = run_command("git worktree remove #{force_flag} #{worktree_path}")

    if success
      puts "Worktree removed: #{worktree_path}".colorize(:green)

      if options[:delete_branch] && branch_name
        puts "Deleting branch '#{branch_name}'...".colorize(:blue)
        if run_command("git branch -D #{branch_name}")
          puts "Branch deleted: #{branch_name}".colorize(:green)
        else
          puts "Failed to delete branch: #{branch_name}".colorize(:red)
        end
      end
    else
      puts "Failed to remove worktree".colorize(:red)
      exit(1)
    end
  end

  desc 'list', 'List all worktrees for the current repository'
  def list
    unless git_repository?
      puts "Error: Not a git repository".colorize(:red)
      exit(1)
    end

    worktrees = get_worktree_list

    if worktrees.empty?
      puts "No worktrees found.".colorize(:yellow)
      return
    end

    table = TTY::Table.new do |t|
      t << ['Topic', 'Branch', 'Path', 'Status']

      worktrees.each do |wt|
        topic = File.basename(wt[:path])
        status = worktree_status(wt[:path])
        t << [topic, wt[:branch], wt[:path], status]
      end
    end

    puts "Git Worktrees:".colorize(:cyan)
    puts table.render(:unicode)
    puts "\nConfigured worktree directory: #{@worktree_dir}".colorize(:light_black)
  end

  desc 'status TOPIC', 'Show status of a specific worktree'
  def status(topic)
    worktree_path = File.join(@worktree_dir, topic)

    unless Dir.exist?(worktree_path)
      puts "Error: Worktree does not exist at #{worktree_path}".colorize(:red)
      exit(1)
    end

    branch_name = get_worktree_branch(worktree_path)

    puts "Worktree: #{topic}".colorize(:cyan)
    puts "Path: #{worktree_path}"
    puts "Branch: #{branch_name}"
    puts ""

    Dir.chdir(worktree_path) do
      system("git status")
    end
  end

  desc 'open TOPIC', 'Open the worktree directory in your editor'
  def open(topic)
    worktree_path = File.join(@worktree_dir, topic)

    unless Dir.exist?(worktree_path)
      puts "Error: Worktree does not exist at #{worktree_path}".colorize(:red)
      exit(1)
    end

    editor = ENV['EDITOR'] || 'code'

    puts "Opening #{worktree_path} in #{editor}...".colorize(:blue)
    system("#{editor} #{worktree_path}")
  end

  private

  def git_repository?
    Dir.exist?('.git') || system('git rev-parse --git-dir > /dev/null 2>&1')
  end

  def get_worktree_dir
    configured_dir = @repo_config&.dig('worktree_dir')

    if configured_dir
      File.expand_path(configured_dir)
    else
      repo_root = `git rev-parse --show-toplevel 2>/dev/null`.strip
      repo_root.empty? ? './worktrees' : File.join(repo_root, 'worktrees')
    end
  end

  def get_default_branch
    default = @repo_config&.dig('default_branch') || 'main'

    branches = `git branch -r`.split("\n").map(&:strip)

    if branches.any? { |b| b.include?("origin/#{default}") }
      default
    elsif branches.any? { |b| b.include?('origin/master') }
      'master'
    else
      default
    end
  end

  def create_worktree_new_branch(topic, from_branch, new_branch, worktree_path)
    puts "Creating worktree for topic: #{topic}".colorize(:blue)
    puts "  Base branch: #{from_branch}".colorize(:light_black)
    puts "  New branch: #{new_branch}".colorize(:light_black)
    puts "  Location: #{worktree_path}".colorize(:light_black)

    if options[:dry_run]
      puts "Would execute: git worktree add -b #{new_branch} #{worktree_path} origin/#{from_branch}".colorize(:blue)
      return
    end

    FileUtils.mkdir_p(File.dirname(worktree_path))

    cmd = "git worktree add -b #{new_branch} #{worktree_path} origin/#{from_branch}"
    success = run_command(cmd)

    unless success
      puts "Failed to create worktree".colorize(:red)
      exit(1)
    end

    puts "Worktree created successfully".colorize(:green)

    copy_env_file(worktree_path)
  end

  def create_worktree_from_existing(topic, branch, worktree_path)
    puts "Creating worktree for topic: #{topic}".colorize(:blue)
    puts "  Existing branch: #{branch}".colorize(:light_black)
    puts "  Location: #{worktree_path}".colorize(:light_black)

    if options[:dry_run]
      puts "Would execute: git worktree add #{worktree_path} #{branch}".colorize(:blue)
      return
    end

    FileUtils.mkdir_p(File.dirname(worktree_path))

    cmd = "git worktree add #{worktree_path} #{branch}"
    success = run_command(cmd)

    unless success
      puts "Failed to create worktree".colorize(:red)
      exit(1)
    end

    puts "Worktree created successfully".colorize(:green)

    copy_env_file(worktree_path)
  end

  def copy_env_file(worktree_path)
    env_file = @repo_config&.dig('env_file') || '.env'

    repo_root = `git rev-parse --show-toplevel 2>/dev/null`.strip
    source_env = File.join(repo_root, env_file)

    return unless File.exist?(source_env)

    dest_env = File.join(worktree_path, env_file)

    if options[:verbose]
      puts "Copying #{env_file} to worktree...".colorize(:light_black)
    end

    begin
      FileUtils.cp(source_env, dest_env)
      puts "Copied #{env_file} to worktree".colorize(:green)
    rescue StandardError => e
      puts "Failed to copy #{env_file}: #{e.message}".colorize(:yellow)
    end
  end

  def worktree_registered?(path)
    worktrees = `git worktree list`.split("\n")
    worktrees.any? { |wt| wt.include?(path) }
  end

  def get_worktree_branch(path)
    output = `git worktree list --porcelain 2>/dev/null`

    output.split("\n\n").each do |wt_block|
      lines = wt_block.split("\n")
      wt_path = lines.find { |l| l.start_with?('worktree ') }&.sub('worktree ', '')
      wt_branch = lines.find { |l| l.start_with?('branch ') }&.sub('branch refs/heads/', '')

      if wt_path == path
        return wt_branch
      end
    end

    nil
  end

  def has_uncommitted_changes?(path)
    Dir.chdir(path) do
      !`git status --porcelain`.strip.empty?
    end
  rescue StandardError
    false
  end

  def get_worktree_list
    output = `git worktree list --porcelain 2>/dev/null`
    worktrees = []

    output.split("\n\n").each do |wt_block|
      lines = wt_block.split("\n")
      wt_path = lines.find { |l| l.start_with?('worktree ') }&.sub('worktree ', '')
      wt_branch = lines.find { |l| l.start_with?('branch ') }&.sub('branch refs/heads/', '')

      next if wt_path == `git rev-parse --show-toplevel`.strip

      next unless wt_path&.start_with?(@worktree_dir)

      worktrees << {
        path: wt_path,
        branch: wt_branch || 'detached',
      }
    end

    worktrees
  end

  def worktree_status(path)
    return 'Missing' unless Dir.exist?(path)

    Dir.chdir(path) do
      status = `git status --porcelain`.strip
      return 'Clean' if status.empty?

      changes = status.lines.count
      "#{changes} changes"
    end
  rescue StandardError
    'Unknown'
  end

  def display_worktree_info(topic, path, branch)
    puts ""
    puts "=" * 60
    puts "Worktree created successfully!".colorize(:green)
    puts "=" * 60
    puts "Topic:    #{topic}".colorize(:cyan)
    puts "Branch:   #{branch}".colorize(:cyan)
    puts "Path:     #{path}".colorize(:cyan)
    puts ""
    puts "To start working:".colorize(:yellow)
    puts "  cd #{path}"
    puts ""
    puts "Or open in your editor:".colorize(:yellow)
    puts "  run agent open #{topic}"
    puts "=" * 60
  end

  def run_command(command, quiet: false)
    puts "Executing: #{command}".colorize(:light_black) if options[:verbose] && !quiet

    if options[:dry_run]
      puts "Would execute: #{command}".colorize(:blue)
      return true
    end

    system(command)
  end

  def detect_project_name
    if Dir.exist?('.git')
      begin
        git_remote = `git remote get-url origin 2>/dev/null`.strip
        if !git_remote.empty?
          name = git_remote.split('/').last.gsub(/\.git$/, '')
          return name unless name.empty?
        end
      rescue StandardError
      end
    end

    File.basename(Dir.pwd)
  end

  def load_repo_config
    return nil unless @project_name

    dotfiles_dir = ENV['DOTFILES_DIR'] || File.expand_path('~/.dotfiles')
    projects_config_dir = File.join(dotfiles_dir, 'run/projects')
    config_file = File.join(projects_config_dir, "#{@project_name}.yml")

    return nil unless File.exist?(config_file)

    YAML.load_file(config_file)
  rescue StandardError => e
    puts "Error loading project config: #{e.message}".colorize(:red) if options[:verbose]
    nil
  end
end
