class EveryoneCanMakeDecisions < ActiveRecord::Migration[6.0]
  def up
    ProviderPermissions.all.each do |permission|
      permission.update!(
        make_decisions: true,
        audit_comment: 'Permission to make decisions automatically granted to all existing provider users',
      )
    end
  end

  def down
    # there is no down
  end
end
