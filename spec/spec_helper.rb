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
  def create_default_user
    Member.first(:email => "krusty@clown.com") || Member.create(:email => "krusty@clown.com",
                   :name => "Krusty the clown",
                   :password => "password",
                   :password_confirmation => "password") or raise "can't create user"
  end

  def login
    user = create_default_user
    request("/login", {
      :method => "PUT",
      :params => {
        :email => user.email,
        :password => "password"
      }
    }).should redirect_to('/')
  end
end

module Merb
  #no async stuff
  def self.run_later(&block)
    block.call
  end
end
  
          