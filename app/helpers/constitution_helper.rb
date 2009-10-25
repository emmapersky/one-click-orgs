module Merb
  module ConstitutionHelper
    def prepare_constitution_view
      @organisation_name = Organisation.name
      @objectives = Organisation.objectives
      @assets = Organisation.assets
      @website = Organisation.domain
  
      @period  = Clause.get_integer('voting_period')
      @voting_period = VotingPeriods.name_for_value(@period)
  
      @general_voting_system = Constitution.voting_system(:general)
      @membership_voting_system = Constitution.voting_system(:membership)
      @constitution_voting_system = Constitution.voting_system(:constitution)
    end
  end
end