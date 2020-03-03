require 'rails_helper'

RSpec.describe 'Notify Callback - POST /integrations/slack/incident-playbook', type: :request do
  it 'returns success if received the corrent request' do
    request_body = {
      stuff: 'pooh'
    }.to_json

    post '/integrations/slack/incident-playbook', headers: headers, params: request_body

    expect(response).to have_http_status(:success)
  end
end
