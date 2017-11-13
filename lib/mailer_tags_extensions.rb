# encoding: utf-8
require 'json'

module MailerTagsExtensions
  include Radiant::Taggable
  
  desc %{
    Renders the mailer form data as json.
  }
  tag 'mailer:to_json' do |tag|
    mail = tag.locals.page.last_mail
    mail.data.to_json
  end
  
  def prior_value(tag, tag_name=tag.attr['name'])
    if mail = tag.locals.page.last_mail
      h(mail.data[tag_name]) unless StringIO === mail.data[tag_name] or Tempfile === mail.data[tag_name]
    else
      prior_database_value(tag_name)
    end
  end
  
  private
  
  def prior_database_value(tag_name)
    @json_hash ||= json_hash
    @json_hash.present? ? @json_hash[tag_name] : nil
  end
  
  def json_hash
    begin
      fd = FormData.find_by_token(@request.parameters[:token])
      fd.present? ? JSON.parse(fd.json_field) : nil
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
end
