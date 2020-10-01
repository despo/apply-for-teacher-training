module CandidateInterface
  module DecoupledReferences
    class ReviewController < BaseController
      before_action :set_reference

      def unsubmitted; end
    end
  end
end
