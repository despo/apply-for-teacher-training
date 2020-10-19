module SupportInterface
  class UCASMatchesController < SupportInterfaceController
    def index
      @matches = UCASMatch.includes(:candidate)
    end

    def show
      @match = UCASMatch.find(params[:id])
    end

    def process_match
      match = UCASMatch.find(params[:id])
      match.update!(matching_state: :processed)
      flash[:success] = 'Match marked as processed'
      redirect_to support_interface_ucas_match_path(match)
    end

    def mark_initial_email_sent
      match = UCASMatch.find(params[:id])
      
      match.update!(initial_email_sent_at: Time.zone.now)
      flash[:success] = 'Match marked as processed'
      redirect_to support_interface_ucas_match_path(match)
    end
  end
end
