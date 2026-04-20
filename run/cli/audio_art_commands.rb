class AudioArtCommands < Thor
  include SystemCommandable

  desc 'add IMAGE MP3_PATTERN', 'Add album art to MP3 file(s) using wildcard pattern'
  method_option :output_dir, aliases: '-o', type: :string, desc: 'Output directory (default: overwrites originals)'
  method_option :backup, aliases: '-b', type: :boolean, default: false, desc: 'Create backup of original files'
  def add(image_file, mp3_pattern)
    unless File.exist?(image_file)
      puts "Error: Image file '#{image_file}' not found".colorize(:red)
      exit(1)
    end

    # Find all matching MP3 files
    mp3_files = Dir.glob(mp3_pattern).select { |f| File.file?(f) }

    if mp3_files.empty?
      puts "Error: No MP3 files found matching pattern '#{mp3_pattern}'".colorize(:red)
      exit(1)
    end

    puts "Found #{mp3_files.size} file(s) to process".colorize(:blue)

    output_dir = options[:output_dir]
    FileUtils.mkdir_p(output_dir) if output_dir && !Dir.exist?(output_dir)

    mp3_files.each do |mp3_file|
      process_file(mp3_file, image_file, output_dir)
    end

    puts "\n✓ Completed processing #{mp3_files.size} file(s)".colorize(:green)
  end

  desc 'remove MP3_PATTERN', 'Remove album art from MP3 file(s) using wildcard pattern'
  method_option :output_dir, aliases: '-o', type: :string, desc: 'Output directory (default: overwrites originals)'
  method_option :backup, aliases: '-b', type: :boolean, default: false, desc: 'Create backup of original files'
  def remove(mp3_pattern)
    mp3_files = Dir.glob(mp3_pattern).select { |f| File.file?(f) }

    if mp3_files.empty?
      puts "Error: No MP3 files found matching pattern '#{mp3_pattern}'".colorize(:red)
      exit(1)
    end

    puts "Found #{mp3_files.size} file(s) to process".colorize(:blue)

    output_dir = options[:output_dir]
    FileUtils.mkdir_p(output_dir) if output_dir && !Dir.exist?(output_dir)

    mp3_files.each do |mp3_file|
      strip_art_from_file(mp3_file, output_dir)
    end

    puts "\n✓ Completed processing #{mp3_files.size} file(s)".colorize(:green)
  end

  private

  def process_file(mp3_file, image_file, output_dir)
    basename = File.basename(mp3_file)
    output_file = if output_dir
                    File.join(output_dir, basename)
                  else
                    # Create temp file with .mp3 extension so ffmpeg recognizes format
                    "#{mp3_file}.tmp.mp3"
                  end

    # Create backup if requested
    if options[:backup]
      backup_file = "#{mp3_file}.bak"
      FileUtils.cp(mp3_file, backup_file)
      puts "  Backup: #{backup_file}".colorize(:light_black)
    end

    # ffmpeg command to add album art
    require 'shellwords'
    command = [
      'ffmpeg',
      '-i', Shellwords.escape(mp3_file),
      '-i', Shellwords.escape(image_file),
      '-map', '0:a',
      '-map', '1:0',
      '-c', 'copy',
      '-id3v2_version', '3',
      '-metadata:s:v', 'title="Album cover"',
      '-metadata:s:v', 'comment="Cover (front)"',
      '-disposition:v:0', 'attached_pic',
      '-y',
      Shellwords.escape(output_file)
    ].join(' ')

    puts "  Processing: #{basename}".colorize(:blue)

    if options[:verbose]
      puts "    #{command}".colorize(:light_black)
    end

    success = system(command + ' 2>/dev/null')

    if success
      if output_file.end_with?('.tmp.mp3')
        FileUtils.mv(output_file, mp3_file)
      end
      puts "    ✓ #{basename}".colorize(:green)
    else
      puts "    ✗ #{basename}".colorize(:red)
      File.delete(output_file) if File.exist?(output_file) && output_file.end_with?('.tmp.mp3')
    end
  end

  def strip_art_from_file(mp3_file, output_dir)
    basename = File.basename(mp3_file)
    output_file = if output_dir
                    File.join(output_dir, basename)
                  else
                    "#{mp3_file}.tmp.mp3"
                  end

    # Create backup if requested
    if options[:backup]
      backup_file = "#{mp3_file}.bak"
      FileUtils.cp(mp3_file, backup_file)
      puts "  Backup: #{backup_file}".colorize(:light_black)
    end

    # ffmpeg command to remove album art
    require 'shellwords'
    command = [
      'ffmpeg',
      '-i', Shellwords.escape(mp3_file),
      '-map', '0:a',
      '-c', 'copy',
      '-y',
      Shellwords.escape(output_file)
    ].join(' ')

    puts "  Processing: #{basename}".colorize(:blue)

    if options[:verbose]
      puts "    #{command}".colorize(:light_black)
    end

    success = system(command + ' 2>/dev/null')

    if success
      if output_file.end_with?('.tmp.mp3')
        FileUtils.mv(output_file, mp3_file)
      end
      puts "    ✓ #{basename}".colorize(:green)
    else
      puts "    ✗ #{basename}".colorize(:red)
      File.delete(output_file) if File.exist?(output_file) && output_file.end_with?('.tmp.mp3')
    end
  end
end
