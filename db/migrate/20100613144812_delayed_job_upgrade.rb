class DelayedJobUpgrade < ActiveRecord::Migration
  def self.up
    Delayed::Backend::ActiveRecord::Job.find(:all).each do |job| 
      handler = job.payload_object

      if handler.respond_to?(:object) && handler.respond_to?(:args)
        if handler.object =~ /CLASS:([A-Z][\w\:]+)/
          handler.object = "LOAD;#{$1}"
        end
        
        handler.args.map! do |arg|
          if arg =~ /AR:([A-Z][\w\:]+):(\d+)/
            "LOAD;#{$1};#{$2}"
          else
            arg
          end
        end
        
        job.update_attributes! :handler=>YAML.dump(handler)
        say "updated #{job}"
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
