module CandidateInterface
  module DecoupledReferences
    class ReviewController < BaseController
      before_action :set_reference

      def unsubmitted
        @submit_reference_form = Reference::RefereeSubmitForm.new
      end
    end
  end
end
