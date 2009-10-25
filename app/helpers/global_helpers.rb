module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  

    def pluralize(n, name)
      "#{n} " + ((n > 1 || n == 0) ?  name.pluralize : name)
    end
    
    def oco_domain
      Constitution.domain or raise "domain not defined"
    end
    
    def absolute_oco_url(name, defaults={})
      oco_domain.concat(Merb::Router.url(name, defaults))
    end
    
    def absolute_oco_resource(name, defaults={})
      oco_domain.concat(Merb::Router.resource(name, defaults))
    end
    
    def time_to_go_in_words(from_time, to_time = Time.now.utc, include_seconds = false, locale=nil)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      
      distance_in_minutes = (((to_time - from_time).abs)/60.0).round
      distance_in_seconds = ((to_time - from_time).abs).round
    
      case distance_in_minutes
        when 0..1
          return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
          case distance_in_seconds
            when 0..4   then 'less than 5 seconds'
            when 5..9   then 'less than 10 seconds'
            when 10..19 then 'less than 20 seconds'
            when 20..39 then 'half a minute'
            when 40..59 then 'less than a minute'
            else             '1 minute'
          end
    
        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then 'about 1 hour'
        when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1440..2879      then '1 day'
        when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
        when 43200..86399    then 'about 1 month'
        when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
        when 525600..1051199 then 'about 1 year'
        else                      "over #{(distance_in_minutes / 525600).round} years"
      end
    end
    
    def get_satisfaction_widget
      <<-EOC
        <script type="text/javascript" charset="utf-8">
          var is_ssl = ("https:" == document.location.protocol);
          var asset_host = is_ssl ? "https://s3.amazonaws.com/getsatisfaction.com/" : "http://s3.amazonaws.com/getsatisfaction.com/";
          document.write(unescape("%3Cscript src='" + asset_host + "javascripts/feedback-v2.js' type='text/javascript'%3E%3C/script%3E"));
        </script>
        <script type="text/javascript" charset="utf-8">
          var feedback_widget_options = {};
          feedback_widget_options.display = "overlay";  
          feedback_widget_options.company = "oneclickorgs";
          feedback_widget_options.placement = "left";
          feedback_widget_options.color = "#222";
          feedback_widget_options.style = "idea";
          var feedback_widget = new GSFN.feedback_widget(feedback_widget_options);
        </script>
      EOC
    end
  end
end
