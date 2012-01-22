require_dependency 'application_controller'
require 'radiant-database_mailer-extension'

class DatabaseMailerExtension < Radiant::Extension
  version     RadiantDatabaseMailerExtension::VERSION
  description RadiantDatabaseMailerExtension::DESCRIPTION
  url         RadiantDatabaseMailerExtension::URL
  
  def activate
    raise "MailerExtension must be loaded before DatabaseMailerExtension" unless defined?(MailerExtension)
    MailController.class_eval do
      include DatabaseMailerProcessing
      alias_method_chain :process_mail, :database
    end

    MailerProcess.class_eval do
      include DatabaseMailerProcessing
      alias_method_chain :process_mail, :database
    end

    tab "Content" do
      add_item "Database Mailer", "/admin/form_datas"
    end

    Mime::Type.register "application/vnd.ms-excel", :xls
  end

  def deactivate
  end
end
