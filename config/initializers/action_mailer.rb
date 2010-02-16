OneClickOrgs::Application.configure do
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.gmail.com',
    :port           => '587',
    :user_name      => 'info@oneclickor.gs',
    :password       => 'XXXX',
    :authentication => :plain
  }
end
