class SendApplyAgainApplicationToProvider
  def self.call(application_form:)
    application_form.application_choices.each do |choice|
      SendApplicationToProvider.new(application_choice: choice).call
    end

    CandidateMailer.application_sent_to_provider(application_form).deliver_later
  end
end
