module SupportInterface
  class ActiveProviderUsersExport
    def self.call
      active_provider_users = ProviderUser.includes(:providers).where.not(last_signed_in_at: nil)

      active_provider_users.map do |provider_user|
        {
          name: provider_user.full_name,
          email_address: provider_user.email_address,
          providers: provider_user.providers.map(&:name).join(', '),
        }
      end
    end
  end
end