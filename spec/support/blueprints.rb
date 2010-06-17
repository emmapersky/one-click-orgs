require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.name     { Faker::Name.name }
Sham.email    { Faker::Internet.email }
Sham.password { Faker::Name.first_name }

MemberClass.blueprint do
  name "Director"
end

Member.blueprint do
  email
  name
  created_at {Time.now - 1.day}
  pw = Sham.password
  password pw
  password_confirmation pw
  active true
  inducted true
  member_class {MemberClass.make}
end

Proposal.blueprint do
  title "a proposal title"
  # Every object inherits Kernel.open, so just calling 'open' doesn't work.
  # This line hacks into Machinist to manually set the 'open' attribute.
  self.send(:assign_attribute, :open, 1)
  proposer {Member.make}
end

Decision.blueprint do
  proposal {Proposal.make}
end

AddMemberProposal.blueprint do
  title "a proposal title"
  self.send(:assign_attribute, :open, 1)
  proposer {Member.make}
end

Clause.blueprint do
  name 'objectives'
  text_value 'consuming doughnuts'
  started_at {Time.now - 1.day}
end
