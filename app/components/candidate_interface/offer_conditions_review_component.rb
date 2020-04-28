module CandidateInterface
  class OfferConditionsReviewComponent < ViewComponent::Base
    validates :conditions, :provider, presence: true

    def initialize(conditions:, provider:)
      @conditions = conditions
      @provider = provider
    end

  private

    attr_reader :conditions, :provider
  end
end
