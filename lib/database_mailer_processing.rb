module DatabaseMailerProcessing
  require 'securerandom' # requires Ruby >= 1.9
  
  def process_mail_with_database(mail, config)
    if mail.valid?
      page = mail.page
      plain_body = (page.part( :email ) ? page.render_part( :email ) : page.render_part( :email_plain ))
      json_field = (page.part( :email_json ) ? page.render_part( :email_json ) : nil)
      token = SecureRandom.uuid # => "96b0a57c-d9ae-453f-b56f-3b154eb10cda"
      
      if config[:save_to_database].to_s == 'true'
        fd = FormData.create(
               mail.data.merge(
                 url:  mail.page.url,
                 blob: plain_body,
                 json_field: json_field,
                 token: token
               )
             )
        # process any assets
        mail.data.each do |k, v|
          if v.class.to_s == "Tempfile"
            FormDataAsset.create(
              form_data_id: fd.id,
              field_name: k,
              attachment: v
            )
          end
        end
      end
      process_mail_without_database(mail, config)
    end
  end
end