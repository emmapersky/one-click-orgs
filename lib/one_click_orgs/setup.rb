module OneClickOrgs
  class Setup
    def self.complete?
      Setting[:base_domain].present?
    end
  end
end
