# frozen_string_literal: true

# Create the admin user used to sign in. Set SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD
# for a known login, otherwise a random password is generated and printed below.
# Re-running only changes the password when SEED_ADMIN_PASSWORD is present.
admin = User.find_or_initialize_by(email: ENV.fetch("SEED_ADMIN_EMAIL", "admin@example.com"))
admin.admin = true
admin.has_access = true

if admin.new_record? || ENV["SEED_ADMIN_PASSWORD"].present?
  password = ENV["SEED_ADMIN_PASSWORD"].presence || SecureRandom.hex(16)
  admin.password = password
  admin.password_confirmation = password
  admin.save!
  puts "Admin user ready: #{admin.email} (password: #{password})"
else
  admin.save!
  puts "Admin user ready: #{admin.email} (password unchanged)"
end
