class YTCommands < Thor
  include SystemCommandable

  desc 'download VIDEO_URL', 'Download a YouTube video from VIDEO_URL using yt-dlp'
  method_option :output, aliases: '-o', type: :string, desc: 'Output file template', default: '%(title)s.%(ext)s'
  def download(video_url)
    output_template = options[:output]
    command = "yt-dlp -o \"#{output_template}\" \"#{video_url}\""
    execute_command(command, "Downloading video from #{video_url}...")
  end
end
