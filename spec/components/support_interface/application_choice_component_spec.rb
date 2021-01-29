require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoiceComponent do
  it 'displays the date an application was rejected' do
    application_choice = create(:application_choice, :with_rejection, rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected at')
    expect(result.text).to include('1 January 2020 at 10:00am')
  end

  it 'displays the date an application was rejected by default' do
    application_choice = create(:application_choice, :with_rejection_by_default, rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected by default at')
    expect(result.text).to include('1 January 2020 at 10:00am')
  end

  it 'displays reasons for rejection on rejected application with structured reasons' do
    application_choice = create(:application_choice, :with_structured_rejection_reasons)

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejection reason')
    expect(result.text).to include('Something you did')
    expect(result.text).to include('Persistent scratching')
  end

  it 'displays reasons for rejection on rejected application without structured reasons' do
    application_choice = create(:application_choice, :with_rejection)

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejection reason')
    expect(result.text).to include(application_choice.rejection_reason)
  end

  it 'displays offer date and DBD date for offered applications' do
    application_choice = create(
      :application_choice,
      :with_offer,
      offered_at: Time.zone.local(2020, 1, 1, 10),
      decline_by_default_at: Time.zone.local(2020, 1, 10, 10),
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Offer made at')
    expect(result.text).to include('1 January 2020 at 10:00am')

    expect(result.text).to include('Decline by default at')
    expect(result.text).to include('10 January 2020 at 10:00am')
  end

  it 'does not display DBD date for offered applications when it has not yet been set' do
    application_choice = create(
      :application_choice,
      :with_offer,
      offered_at: Time.zone.local(2020, 1, 1, 10),
      decline_by_default_at: nil,
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).not_to include('Decline by default at')
  end
end
