module CandidateInterface
  class Ethnicity::BaseController < CandidateInterfaceController
    # before_action :redirect_to_dashboard_if_not_amendable

    def new
    end

    def specify
      if params[:etnicity] == "prefer_not_to_say"
        render review
      end
      render :background
    end

    def background
    end

    def create
    end

    def review
    end
  end
end
