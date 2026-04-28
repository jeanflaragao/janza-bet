# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development? || Rails.env.test?
  user = User.find_or_initialize_by(email_address: "admin@janzabet.local")
  user.assign_attributes(
    password: "password123",
    password_confirmation: "password123",
    confirmed_at: Time.current
  )
  user.save!
  puts "Seed user ready — email: admin@janzabet.local / password: password123"
end
