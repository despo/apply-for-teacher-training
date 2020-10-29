module SupportInterface
  class UCASMatchesController < SupportInterfaceController
    def index
      @filter = SupportInterface::MatchesFilter.new(params: params)
      @matches = @filter.filter_records(
        UCASMatch
        .includes(:candidate)
        .order(updated_at: :desc)
        .page(params[:page] || 1).per(15),
      )
    end

    def show
      @match = UCASMatch.find(params[:id])
    end

    def audit
      @match = UCASMatch.find(params[:id])
    end

    def process_match
      match = UCASMatch.find(params[:id])
      match.update!(matching_state: :processed)
      flash[:success] = 'Match marked as processed'
      redirect_to support_interface_ucas_match_path(match)
    end
  end
end
