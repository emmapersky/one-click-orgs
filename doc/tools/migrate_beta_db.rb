#!/usr/local/bin/ruby
# migrate_beta_db.rb
#
# Migrates v0.6.0 (beta) databases to a shared v1.0 database (with multi-tenancy support.)
#
# Usage:
# * Set up the target DB (via OCO's db:setup rake task)
# * Set the base_domain property (via OCO setup screen)
# * Migrate each beta DB individually into the new target DB (using this script)
#
# Parameters:
# $ ruby migrate_beta_db.rb <source DB connection string> <target DB connection string> <org subdomain> 
#

require 'rubygems' 
require 'sequel'

# =========
# = Tools =
# =========

# Migrate rows from one DB to another, translating primary keys.
# Returns a mapping: old PK => new PK
def migrate_rows(src, dst, pk_column=:id, &block)
  pk_map = {}
  src.order(pk_column).each do |row|
    old_pk = row[pk_column]
    row[pk_column] = nil
    new_row = yield row
    new_pk = dst.insert(new_row)
    pk_map[old_pk] = new_pk
  end
  pk_map
end

# ========
# = Main =
# ========

if ARGV.size!=3 then
  puts "<mysql://username:password@host/source_db> <mysql://username:password@host/target_db> <org subdomain>"
  exit 1
end

DB1 = Sequel.connect(ARGV[0])
DB2 = Sequel.connect(ARGV[1])
subdomain = ARGV[2]

# TODO: can we determine when a beta org was founded? Here we're using the timestamp of the earliest Clause
org_created_at = DB1[:clauses].min(:started_at)

# Settings
#DB2[:settings].insert(:key => 'base_domain', :value => 'oneclickorgs.com')

# Create org
org_id = DB2[:organisations].insert(:subdomain => subdomain, :created_at => org_created_at, :updated_at => Time.now)
puts "Org: #{subdomain}, id: #{org_id}"

# Clauses
clause_pks = migrate_rows(DB1[:clauses], DB2[:clauses]) do |row|
  row[:organisation_id] = org_id
  row
end
puts "Migrated #{clause_pks.size} clauses."

# Member classes
member_class_id = DB2[:member_classes].insert(:name => 'Member', :organisation_id => org_id)
DB2[:clauses].insert(:name => 'permission_member_constitution_proposal', :started_at => org_created_at, :boolean_value => true, :organisation_id => org_id)
DB2[:clauses].insert(:name => 'permission_member_membership_proposal', :started_at => org_created_at, :boolean_value => true, :organisation_id => org_id)
DB2[:clauses].insert(:name => 'permission_member_freeform_proposal', :started_at => org_created_at, :boolean_value => true, :organisation_id => org_id)
DB2[:clauses].insert(:name => 'permission_member_vote', :started_at => org_created_at, :boolean_value => true, :organisation_id => org_id)

# Members
member_pks = migrate_rows(DB1[:members], DB2[:members]) do |row|
  # TODO: what happens if we leave invitation_code, password_reset_code empty?
  # TODO: will old login still work on new system? (Don't have access to beta accounts. Login with a new password worked fine.)
  inducted = row[:inducted]; row.delete(:inducted)
  if (inducted==1) then
    row[:inducted_at] = row[:created_at]
  end
  
  name = row[:name]; row.delete(:name)
  first_name, last_name = name.split(' ', 2)
  row[:first_name] = first_name
  row[:last_name] = last_name
  
  row[:organisation_id] = org_id
  row[:member_class_id] = member_class_id
  row
end
puts "Migrated #{member_pks.size} members."

# Proposals
proposal_pks = migrate_rows(DB1[:proposals], DB2[:proposals]) do |row|
  # TODO: type: did proposal class names change?
  row[:organisation_id] = org_id
  row[:proposer_member_id] = member_pks[row[:proposer_member_id]]
  row
end
puts "Migrated #{proposal_pks.size} proposals."

# Decisions
decision_pks = migrate_rows(DB1[:decisions], DB2[:decisions]) do |row|
  row[:proposal_id] = proposal_pks[row[:proposal_id]]
  row
end
puts "Migrated #{decision_pks.size} decisions."

# Votes
vote_pks = migrate_rows(DB1[:votes], DB2[:votes]) do |row|
  row[:proposal_id] = proposal_pks[row[:proposal_id]]
  row[:member_id] = member_pks[row[:member_id]]
  row
end
puts "Migrated #{vote_pks.size} votes."

