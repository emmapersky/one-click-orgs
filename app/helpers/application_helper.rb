module ApplicationHelper
  def oco_domain
    Organisation.domain or raise "domain not defined"
  end
  
  def absolute_oco_url(name, defaults={})
    oco_domain.concat(url_for(name, defaults.merge(:only_path => true)))
  end
  
  def absolute_oco_resource(name, defaults={})
    oco_domain.concat(url_for(name, defaults.merge(:only_path => true)))
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
