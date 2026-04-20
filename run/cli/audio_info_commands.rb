class AudioInfoCommands < Thor
  include SystemCommandable

  desc 'list MP3_PATTERN', 'List metadata for MP3 file(s) using wildcard pattern'
  method_option :format, aliases: '-f', type: :string, default: 'table', desc: 'Output format: table or json'
  def list(mp3_pattern)
    mp3_files = Dir.glob(mp3_pattern).select { |f| File.file?(f) }

    if mp3_files.empty?
      puts "Error: No MP3 files found matching pattern '#{mp3_pattern}'".colorize(:red)
      exit(1)
    end

    if options[:format] == 'json'
      list_as_json(mp3_files)
    else
      list_as_table(mp3_files)
    end
  end

  desc 'show MP3_FILE', 'Show detailed metadata for a specific MP3 file'
  method_option :format, aliases: '-f', type: :string, default: 'pretty', desc: 'Output format: pretty or json'
  def show(mp3_file)
    unless File.exist?(mp3_file)
      puts "Error: File '#{mp3_file}' not found".colorize(:red)
      exit(1)
    end

    if options[:format] == 'json'
      command = "ffprobe -v quiet -print_format json -show_format -show_streams \"#{mp3_file}\""
      system(command)
    else
      show_pretty(mp3_file)
    end
  end

  private

  def list_as_table(mp3_files)
    require 'tty-table'

    puts "Found #{mp3_files.size} file(s)".colorize(:blue)
    puts

    table = TTY::Table.new(header: ['File', 'Title', 'Artist', 'Album', 'Duration', 'Art'])

    mp3_files.each do |file|
      metadata = extract_metadata(file)
      table << [
        File.basename(file),
        truncate(metadata[:title] || '-', 30),
        truncate(metadata[:artist] || '-', 25),
        truncate(metadata[:album] || '-', 25),
        metadata[:duration] || '-',
        metadata[:has_art] ? '✓' : '✗'
      ]
    end

    puts table.render(:unicode, padding: [0, 1])
  end

  def list_as_json(mp3_files)
    results = mp3_files.map do |file|
      metadata = extract_metadata(file)
      {
        file: file,
        metadata: metadata
      }
    end

    puts JSON.pretty_generate(results)
  end

  def show_pretty(mp3_file)
    metadata = extract_metadata(mp3_file)

    puts "File: #{mp3_file}".colorize(:cyan)
    puts "─" * 80

    puts "Audio Metadata:".colorize(:yellow)
    puts "  Title:    #{metadata[:title] || 'N/A'}"
    puts "  Artist:   #{metadata[:artist] || 'N/A'}"
    puts "  Album:    #{metadata[:album] || 'N/A'}"
    puts "  Year:     #{metadata[:year] || 'N/A'}"
    puts "  Genre:    #{metadata[:genre] || 'N/A'}"
    puts "  Duration: #{metadata[:duration] || 'N/A'}"
    puts "  Bitrate:  #{metadata[:bitrate] || 'N/A'}"

    puts "\nAlbum Art:".colorize(:yellow)
    puts "  Present:  #{metadata[:has_art] ? 'Yes ✓'.colorize(:green) : 'No ✗'.colorize(:red)}"

    if metadata[:has_art] && metadata[:art_info]
      puts "  Format:   #{metadata[:art_info][:codec] || 'N/A'}"
      puts "  Size:     #{metadata[:art_info][:size] || 'N/A'}"
    end
  end

  def extract_metadata(file)
    # Use ffprobe to extract metadata
    require 'shellwords'
    command = "ffprobe -v quiet -print_format json -show_format -show_streams #{Shellwords.escape(file)} 2>/dev/null"
    output = `#{command}`

    begin
      data = JSON.parse(output)
      format = data['format'] || {}
      tags = format['tags'] || {}

      # Find video stream (album art)
      video_stream = data['streams']&.find { |s| s['codec_type'] == 'video' }
      audio_stream = data['streams']&.find { |s| s['codec_type'] == 'audio' }

      duration_seconds = format['duration']&.to_f
      duration = if duration_seconds
                   format_duration(duration_seconds)
                 else
                   nil
                 end

      bitrate = if format['bit_rate']
                  "#{(format['bit_rate'].to_i / 1000).round}kbps"
                else
                  nil
                end

      art_info = if video_stream
                   {
                     codec: video_stream['codec_name'],
                     size: "#{video_stream['width']}x#{video_stream['height']}"
                   }
                 else
                   nil
                 end

      {
        title: tags['title'],
        artist: tags['artist'],
        album: tags['album'],
        year: tags['date'] || tags['year'],
        genre: tags['genre'],
        duration: duration,
        bitrate: bitrate,
        has_art: !video_stream.nil?,
        art_info: art_info
      }
    rescue JSON::ParserError, StandardError
      {
        title: nil,
        artist: nil,
        album: nil,
        year: nil,
        genre: nil,
        duration: nil,
        bitrate: nil,
        has_art: false,
        art_info: nil
      }
    end
  end

  def format_duration(seconds)
    minutes = (seconds / 60).to_i
    secs = (seconds % 60).to_i
    "#{minutes}:#{secs.to_s.rjust(2, '0')}"
  end

  def truncate(string, max_length)
    return string if string.length <= max_length
    "#{string[0...max_length - 1]}…"
  end
end
