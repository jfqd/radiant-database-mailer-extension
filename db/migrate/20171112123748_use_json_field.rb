class UseJsonField < ActiveRecord::Migration
  def self.up
    add_column :form_datas, :json_field, :text
    add_column :form_datas, :site_id,    :integer
    add_column :form_datas, :token,      :string
    add_index  :form_datas, :token
  end
  
  def self.down
  end
end