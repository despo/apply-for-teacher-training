module SupportInterface
  class UCASMatchesController < SupportInterfaceController
    def index
      @matches = UCASMatch.includes(:candidate)
    end

    def show
      @match = UCASMatch.find(params[:id])
    end

    def record_initial_email_sent
      match = UCASMatch.find(params[:id])
      match.update!(
        candidate_last_contacted_at: Time.zone.now,
        matching_state: 'initial_emails_sent',
      )
      flash[:success] = 'The date of the initial emails was recorded'
      redirect_to support_interface_ucas_match_path(match)
    end

    def record_reminder_emails_sent_email_sent
      match = UCASMatch.find(params[:id])
      match.update!(
        candidate_last_contacted_at: Time.zone.now,
        matching_state: 'reminder_emails_sent',
      )
      flash[:success] = 'The date of the reminder emails was recorded'
      redirect_to support_interface_ucas_match_path(match)
    end

    def record_ucas_withdrawal_requested
      match = UCASMatch.find(params[:id])
      match.update!(
        candidate_last_contacted_at: Time.zone.now,
        matching_state: 'ucas_withdrawal_requested',
      )
      flash[:success] = 'The date of requesting withdrawal from UCAS was recorded'
      redirect_to support_interface_ucas_match_path(match)
    end

    def process_match
      match = UCASMatch.find(params[:id])
      match.update!(matching_state: :processed)
      flash[:success] = 'Match marked as processed'
      redirect_to support_interface_ucas_match_path(match)
    end
  end
end
