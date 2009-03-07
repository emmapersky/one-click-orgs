require 'faker'

Sham.name     { Faker::Name.name }
Sham.email    { Faker::Internet.email }
Sham.password { Faker::Name.first_name }

Member.blueprint do
  email "foo@example.com"
  name Sham.name
  created_at Time.now - 1.day
  pw = Sham.password
  password pw
  password_confirmation pw
end

Decision.blueprint do
  title "a proposal title"
end
