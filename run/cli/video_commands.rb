class VideoCommands < Thor
  include SystemCommandable

  desc 'clip INPUT_FILE', 'Extract n seconds from a video clip'
  method_option :duration, aliases: '-d', type: :numeric, default: 60, desc: 'Duration in seconds (default: 60)'
  method_option :start, aliases: '-s', type: :numeric, default: 0, desc: 'Start time in seconds (default: 0)'
  method_option :output, aliases: '-o', type: :string, desc: 'Output file path'
  def clip(input_file)
    unless File.exist?(input_file)
      puts "Error: Input file '#{input_file}' not found".colorize(:red)
      exit(1)
    end

    duration = options[:duration]
    start_time = options[:start]
    output_file = options[:output] || "#{File.basename(input_file, '.*')}_clip.#{File.extname(input_file)[1..-1]}"

    command = build_clip_command(input_file, output_file, start_time, duration)
    execute_command(command, "Extracting #{duration}s clip from #{input_file} starting at #{start_time}s...")
  end

  private

  def build_clip_command(input_file, output_file, start_time, duration)
    # Use ffmpeg to extract a clip from start_time for duration seconds
    # -ss: start time
    # -t: duration
    # -c copy: copy codec (fast, no re-encoding)
    "ffmpeg -ss #{start_time} -i \"#{input_file}\" -t #{duration} -c copy \"#{output_file}\""
  end
end
