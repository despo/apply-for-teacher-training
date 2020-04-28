require 'rails_helper'

RSpec.describe ApplicationStateChange do
  describe '.valid_states' do
    it 'has human readable translations' do
      expect(ApplicationStateChange.valid_states)
        .to match_array(I18n.t('application_states').keys)

      expect(ApplicationStateChange.valid_states + [:offer_withdrawn])
        .to match_array(I18n.t('candidate_application_states').keys)

      expect(ApplicationStateChange.valid_states + [:offer_withdrawn])
        .to match_array(I18n.t('provider_application_states').keys)
    end

    it 'has corresponding entries in the ApplicationChoice#status enum' do
      expect(ApplicationStateChange.valid_states)
        .to match_array(ApplicationChoice.statuses.keys.map(&:to_sym))
    end
  end

  describe '.states_visible_to_provider' do
    it 'has corresponding entries in the OpenAPI spec' do
      valid_states_in_openapi = VendorAPI::OpenAPISpec.as_hash['components']['schemas']['ApplicationAttributes']['properties']['status']['enum']

      expect(ApplicationStateChange.states_visible_to_provider)
        .to match_array(valid_states_in_openapi.map(&:to_sym))
    end
  end

  describe '::STATES_NOT_VISIBLE_TO_PROVIDER' do
    it 'contains the correct states to filter by' do
      expect(ApplicationStateChange.valid_states).to include(*ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER)
    end
  end
end
