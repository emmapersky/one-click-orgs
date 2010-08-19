# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Set up a simple organisation: all members are equal
members = MemberClass.find_or_create_by_name('Member')
members.set_permission(:constitution_proposal, true)
members.set_permission(:membership_proposal, true)
members.set_permission(:freeform_proposal, true)
members.set_permission(:vote, true)