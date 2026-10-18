namespace :users do
  desc "Create a user with a random password: bin/rails users:create EMAIL=x [FIRST_NAME=y LAST_NAME=z]"
  task create: :environment do
    email = ENV.fetch("EMAIL") { abort "EMAIL is required" }
    abort "User #{email} already exists" if User.exists?(email: email)

    password = SecureRandom.alphanumeric(16)
    User.create!(
      email: email,
      first_name: ENV["FIRST_NAME"],
      last_name: ENV["LAST_NAME"],
      password: password,
      password_confirmation: password
    )

    puts "Created #{email}"
    puts "Password: #{password}"
  end
end
