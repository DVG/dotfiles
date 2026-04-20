class ConvertCommands < Thor
  include SystemCommandable

  desc 'video INPUT_FILE', 'Convert video to different formats (e.g., webm to mp3)'
  method_option :format, aliases: '-f', type: :string, required: true, desc: 'Output format (e.g., mp3, mp4, wav)'
  method_option :output, aliases: '-o', type: :string, desc: 'Output file path'
  def video(input_file)
    unless File.exist?(input_file)
      puts "Error: Input file '#{input_file}' not found".colorize(:red)
      exit(1)
    end

    format = options[:format]
    output_file = options[:output] || "#{File.basename(input_file, '.*')}.#{format}"

    command = build_ffmpeg_command(input_file, output_file, format)
    execute_command(command, "Converting #{input_file} to #{format}...")
  end

  private

  def build_ffmpeg_command(input_file, output_file, format)
    case format.downcase
    when 'mp3'
      # Extract audio only, convert to mp3
      "ffmpeg -i \"#{input_file}\" -vn -acodec libmp3lame -q:a 2 \"#{output_file}\""
    when 'wav'
      # Extract audio only, convert to wav
      "ffmpeg -i \"#{input_file}\" -vn \"#{output_file}\""
    when 'mp4'
      # Convert video to mp4
      "ffmpeg -i \"#{input_file}\" -c:v libx264 -c:a aac \"#{output_file}\""
    when 'webm'
      # Convert to webm
      "ffmpeg -i \"#{input_file}\" -c:v libvpx-vp9 -c:a libopus \"#{output_file}\""
    else
      # Generic conversion, let ffmpeg figure it out
      "ffmpeg -i \"#{input_file}\" \"#{output_file}\""
    end
  end
end
