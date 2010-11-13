require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.name       { Faker::Name.name }
Sham.email      { Faker::Internet.email }
Sham.password   { Faker::Name.first_name }
Sham.first_name { Faker::Name.first_name }
Sham.last_name  { Faker::Name.last_name }
Sham.subdomain  { Faker::Internet.domain_word }

MemberClass.blueprint do
  name "Director"
  organisation
end

Member.blueprint do
  email
  first_name
  last_name
  created_at {Time.now - 1.day}
  pw = Sham.password
  password pw
  password_confirmation pw
  active true
  inducted_at {Time.now - 23.hours}
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

Setting.blueprint do
  key 'base_domain'
  value 'oneclickorgs.com'
end

Organisation.blueprint do
  subdomain
end
