# db_commands.rb
# Database access commands (AWS RDS auth tokens, etc.)

class DbCommands < Thor
  include Thor::Actions
  include SystemCommandable

  DB_HOSTS = {
    'stage' => 'arkestro-api-stage.cvwxbaczr2pm.us-west-2.rds.amazonaws.com',
    'prod' => 'arkestro-api-prod.cvwxbaczr2pm.us-west-2.rds.amazonaws.com'
  }.freeze

  DB_PORT = 5432
  DB_REGION = 'us-west-2'
  DB_USERNAME = 'engineer'
  SSO_LOGIN_PROFILE = 'login'

  AWS_PROFILES = {
    'stage' => 'arkestro-stage-services/aws-sso-services-stage-engineer',
    'prod' => 'arkestro-prod-services/aws-sso-services-prod-engineer'
  }.freeze

  class_option :verbose, type: :boolean, aliases: '-v', desc: 'Verbose output'

  desc 'password ENV', 'Generate RDS auth token for database access (stage or prod)'
  def password(env)
    env = env.downcase

    unless DB_HOSTS.key?(env)
      puts "Error: Unknown environment '#{env}'".colorize(:red)
      puts "Valid environments: #{DB_HOSTS.keys.join(', ')}"
      exit(1)
    end

    hostname = DB_HOSTS[env]
    aws_profile = AWS_PROFILES[env]

    puts "Logging into AWS SSO...".colorize(:blue)
    login_success = system({ 'AWS_PROFILE' => SSO_LOGIN_PROFILE }, 'aws-sso-util login')

    unless login_success
      puts "Error: AWS SSO login failed".colorize(:red)
      exit(1)
    end

    puts "Generating database auth token for #{env}...".colorize(:blue)

    cmd = [
      'aws', 'rds', 'generate-db-auth-token',
      '--hostname', hostname,
      '--port', DB_PORT.to_s,
      '--region', DB_REGION,
      '--username', DB_USERNAME
    ]

    if options[:verbose]
      puts "Command: AWS_PROFILE=#{aws_profile} #{cmd.join(' ')}".colorize(:light_black)
    end

    token = nil
    IO.popen({ 'AWS_PROFILE' => aws_profile }, cmd, err: [:child, :out]) do |io|
      token = io.read.strip
    end

    if $?.success? && token && !token.empty?
      IO.popen('pbcopy', 'w') { |clipboard| clipboard.print token }

      puts "Database auth token copied to clipboard!".colorize(:green)
      puts ""
      puts "Environment: #{env}".colorize(:cyan)
      puts "Host:        #{hostname}".colorize(:cyan)
      puts "Username:    #{DB_USERNAME}".colorize(:cyan)
      puts "Port:        #{DB_PORT}".colorize(:cyan)
      puts ""
      puts "Paste the token as your password when connecting.".colorize(:yellow)
    else
      puts "Error: Failed to generate auth token".colorize(:red)
      puts token if token && !token.empty?
      exit(1)
    end
  end
end
