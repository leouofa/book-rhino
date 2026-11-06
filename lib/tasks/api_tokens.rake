# frozen_string_literal: true

namespace :api_tokens do
  desc 'Generate a new API token for a user: rake api_tokens:create[user@example.com,TokenName,optional_days]'
  task :create, %i[email name days] => :environment do |_t, args|
    email = args[:email] || ENV['EMAIL']
    name = args[:name] || ENV['NAME'] || 'MCP Client'
    days = args[:days] || ENV['DAYS']

    unless email
      puts "Error: email is required. Usage: rake 'api_tokens:create[user@example.com,TokenName]'"
      exit 1
    end

    user = User.find_by(email: email)
    unless user
      puts "Error: User with email '#{email}' not found."
      exit 1
    end

    expires_at = days.present? ? days.to_i.days.from_now : nil
    token = ApiToken.generate_for!(user: user, name: name, expires_at: expires_at)

    puts "\nAPI Token created successfully for #{user.email}!"
    puts "Name:       #{token.name}"
    puts "Prefix:     #{token.token_prefix}"
    puts "Expires at: #{token.expires_at || 'Never'}"
    puts "Token:      #{token.raw_token}"
    puts "\nSave this token securely. It will not be shown again."
  end

  desc 'List API tokens for a user: rake api_tokens:list[user@example.com]'
  task :list, [:email] => :environment do |_t, args|
    email = args[:email] || ENV['EMAIL']

    scope = email.present? ? User.find_by!(email: email).api_tokens : ApiToken.all
    puts format("\n%-6s %-25s %-18s %-20s %-12s", 'ID', 'Name', 'Prefix', 'User', 'Status')
    puts '-' * 85

    scope.includes(:user).order(created_at: :desc).each do |token|
      status = if token.revoked_at.present?
                 'REVOKED'
               elsif token.expires_at.present? && token.expires_at.past?
                 'EXPIRED'
               else
                 'ACTIVE'
               end

      puts format(
        '%-6s %-25s %-18s %-20s %-12s',
        token.id,
        token.name.truncate(24),
        token.token_prefix,
        token.user.email.truncate(19),
        status
      )
    end
    puts "\n"
  end

  desc 'Revoke an API token: rake api_tokens:revoke[token_id]'
  task :revoke, [:id] => :environment do |_t, args|
    token_id = args[:id] || ENV['ID']
    unless token_id
      puts 'Error: token id is required. Usage: rake api_tokens:revoke[123]'
      exit 1
    end

    token = ApiToken.find_by(id: token_id)
    unless token
      puts "Error: ApiToken with id #{token_id} not found."
      exit 1
    end

    token.revoke!
    puts "API token #{token.id} ('#{token.name}') has been revoked."
  end
end
