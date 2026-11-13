class AddAdminToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :admin, :boolean, default: false, null: false
    # Both current users (the osteopath, who is the data controller, and the developer,
    # who is the processor) must be able to review the access log.
    execute "UPDATE users SET admin = TRUE"
  end

  def down
    remove_column :users, :admin
  end
end
