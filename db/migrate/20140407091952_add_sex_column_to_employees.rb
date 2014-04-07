class AddSexColumnToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :sex, :string, defalut: 'not entered'
  end
end
