migration 1, :rename_decisions_to_proposals  do
  up do
    execute("ALTER TABLE decisions RENAME TO proposals")
  end

  down do
  end
end
