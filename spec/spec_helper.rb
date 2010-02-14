require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
require 'dm-machinist' 

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
DataMapper.auto_migrate!

require File.join(Merb.root, 'spec', 'blueprint')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)

  config.after(:each) do
    repository(:default) do
      while repository.adapter.current_transaction
        repository.adapter.current_transaction.rollback
        repository.adapter.pop_transaction
      end
    end
  end
 
  config.before(:each) do
    Merb::Mailer.deliveries.clear
    
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
  end
    
end

module DataMapper
  module Machinist
    module DataMapperExtentions
      def make_n(n,  attributes={})
        Array.new(n) { make(attributes) }
      end
    end
  end
end

Merb::Test.add_helpers do
  
  def h(s) CGI.escapeHTML(s.to_s) end
    
  def default_user
    stub_constitution!
    stub_organisation!
      
    Member.first(:email => "krusty@clown.com") || 
      Member.create(:email => "krusty@clown.com",
                   :name => "Krusty the clown",
                   :password => "password",
                   :password_confirmation => "password",
                   :inducted => true) or raise "can't create user"
  end

  def stub_constitution!
    Constitution.stub!(:voting_period).and_return(3 * 86400)
#    Constitution.stub!(:voting_system).and_return(VotingSystems.get(:RelativeMajority))
  end
  
  def stub_organisation!
    organisation_is_active
    Organisation.stub!(:domain).and_return('http://test.com')
    Organisation.stub!(:name).and_return('test')
  end
  
  def login
    @user = default_user
    request("/login", {
      :method => "PUT",
      :params => {
        :email => @user.email,
        :password => "password"
      }
    }).should redirect_to('/')
    @user
  end
  
  
  def passed_proposal(p, args={})
    p.stub!(:passed?).and_return(true)
    lambda { p.enact!(args) }
  end
  
  def organisation_is_pending
    # FIXME should be Organistaion.stub!(:state)
    
    Organisation.stub!(:pending?).and_return(true)      
    Organisation.stub!(:active?).and_return(false)      
    Organisation.stub!(:under_construction?).and_return(false)
  end
  
  def organisation_is_active
    # FIXME should be Organistaion.stub!(:state)
    
    Organisation.stub!(:pending?).and_return(false)      
    Organisation.stub!(:active?).and_return(true)      
    Organisation.stub!(:under_construction?).and_return(false)
  end

  def organisation_is_under_construction
    # FIXME should be Organistaion.stub!(:state)
    
    Organisation.stub!(:pending?).and_return(false)      
    Organisation.stub!(:active?).and_return(false)      
    Organisation.stub!(:under_construction?).and_return(true)
  end  
end

module Merb
  #no async stuff
  def self.run_later(&block)
    block.call
  end
end

module MailControllerTestHelper          
  def clear_mail_deliveries
    Merb::Mailer.deliveries.clear
  end

  def last_delivered_mail
    Merb::Mailer.deliveries.last
  end
end
