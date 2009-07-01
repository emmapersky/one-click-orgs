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

Proposal.blueprint do |bp|
  bp.title "a proposal title"
  bp.open "1"
#  bp.proposer Member.make  
end

AddMemberProposal.blueprint do |bp|
  bp.title "a proposal title"
  bp.open "1"
  bp.proposer Member.make
end

Clause.blueprint do |bp|
  bp.name 'objectives'
  bp.text_value 'consuming doughnuts'
  bp.started_at(Time.now - 1.day)
end
