require RUBY_VERSION < "1.9" ? 'fastercsv' : 'csv'
require 'spreadsheet'

class FormData < ActiveRecord::Base
  
  # secure text fields
  if defined?(CryptoMaster)
    acts_as_secure crypto_provider: CryptoMaster,
                   storage_type:    :text
  end

  has_many :form_data_assets, :dependent => :destroy

  SORT_COLUMNS = DATABASE_MAILER_COLUMNS.keys.map(&:to_s) + ['created_at', 'url', 'exported']
  FILTER_COLUMNS = DATABASE_MAILER_COLUMNS.keys + [:url]

  DATABASE_MAILER_COLUMNS.each_key do | col |
    FormData.named_scope :"by_#{col}", lambda { |item|
      {:conditions => ["LOWER(#{col}) LIKE ?", "%#{item.to_s.downcase}%"]}
    }
  end
  named_scope :by_url, lambda{ |item| {:conditions => ["url = ?", item]}}
  named_scope :not_exported, :conditions => {:exported => nil}

  def self.form_paginate(params)
    options = {
      :page => params[:page],
      :per_page => Radiant::Config['database_mailer.per_page'] || 25,
    }
    if SORT_COLUMNS.include?(params[:sort_by]) && %w(asc desc).include?(params[:sort_order])
      options[:order] = "#{params[:sort_by]} #{params[:sort_order]}"
    end
    params.reject { |k, v| !FILTER_COLUMNS.include?(k) }.
      inject(FormData) { |scope, pair| pair[1].blank? ? scope : scope.send(:"by_#{pair[0]}", pair[1]) }.
      paginate(options)
  end
  
  def self.find_all_group_by_url
     find(:all, :group => 'url', :select => 'url')
  end
  
  def self.find_for_export(params, export_all)
    options = {}
    if SORT_COLUMNS.include?(params[:sort_by]) && %w(asc desc).include?(params[:sort_order])
      options[:order] = "#{params[:sort_by]} #{params[:sort_order]}"
    end
    
    initial = export_all ? FormData : FormData.not_exported
    
    params.reject { |k, v| !FILTER_COLUMNS.include?(k) }.
      inject(initial) { |scope, pair| pair[1].blank? ? scope : scope.send(:"by_#{pair[0]}", pair[1]) }.find(:all, :order => options[:order])
  end
  
  def self.export_csv(params, selected_export_columns, exported_at, export_all=false)
    @items = find_for_export(params, export_all)
    csv_handler = RUBY_VERSION < "1.9" ? FasterCSV : CSV
    
    csv_handler.generate do |csv|
      csv << selected_export_columns.map{|k| k.capitalize}
      @items.each do |ei|
        csv << selected_export_columns.map do |k|
          formatting_for_csv(ei.send(k))
        end
        ei.exported = exported_at.to_s(:db)
        ei.save
      end
    end
  end
  
  def self.export_xls(params, selected_export_columns, exported_at, export_all=false)
    items = find_for_export(params, export_all)
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => 'Form Data'
    
    sheet.row(0).replace(selected_export_columns.map{|k| k.capitalize})
    
    items.each_with_index do |item, i|
      sheet.row(i+1).replace(selected_export_columns.map {|k| item.send(k)})
      item.exported = exported_at.to_s(:db)
      item.save
    end
    
    tmp_file = Tempfile.new("form_data")
    book.write tmp_file
    tmp_file.path
  end
  
  def self.formatting_for_csv(item)
    if Time === item
      item.to_s(:db)
    else
      item.to_s.gsub(/\s/, ' ')
    end
  end

  def initialize(params={})
    data = params.dup.delete_if { |k, v| !self.class.column_names.include?(k.to_s) }
    super(data)
  end
end