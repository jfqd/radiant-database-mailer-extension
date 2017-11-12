# encoding: utf-8
require 'json'

module MailerTagsExtensions
  include Radiant::Taggable
  
  desc %{
    Renders the mailer form data as json.
  }
  tag 'mailer:to_json' do |tag|
    mail = tag.locals.page.last_mail
    mail.to_json
  end
  
end
