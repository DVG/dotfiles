module SystemCommandable
  protected

  def execute_command(command, message = nil)
    puts message.colorize(:blue) if message

    if options[:verbose]
      puts "Executing: #{command}".colorize(:light_black)
    end

    success = system(command)

    if success
      puts "Completed successfully".colorize(:green)
    else
      puts "Command failed".colorize(:red)
      exit(1)
    end
  end
end
