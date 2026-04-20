require_relative 'audio_art_commands'
require_relative 'audio_info_commands'

class AudioCommands < Thor
  include SystemCommandable

  desc 'art SUBCOMMAND', 'Manage album art for audio files'
  subcommand 'art', AudioArtCommands

  desc 'info SUBCOMMAND', 'View metadata information for audio files'
  subcommand 'info', AudioInfoCommands
end
