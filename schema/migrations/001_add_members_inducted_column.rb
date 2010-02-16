migration 1, :add_members_inducted_column  do
  up do
    modify_table :members do
      add_column :inducted, DataMapper::Types::Boolean, :nullable? => false, :default => false
    end
  end

  down do
    modify_table :members do
      drop_column :inducted
    end
  end
end
