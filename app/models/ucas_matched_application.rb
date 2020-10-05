class UCASMatchedApplication
  def initialize(matching_data)
    @matching_data = matching_data
  end

  def course
    Course.find_by(code: @matching_data['Course code'], provider: Provider.find_by(code: @matching_data['Provider code']))
  end

  def scheme
    @matching_data['Scheme']
  end

  def ucas_scheme?
    scheme == 'U'
  end

  def dfe_scheme?
    scheme == 'D'
  end

  def both_scheme?
    scheme == 'B'
  end

  def status
    if ucas_scheme?
      mapped_ucas_status
    else
      ApplicationForm.find_by(candidate_id: @matching_data['Apply candidate ID'])
        .application_choices.find_by(course_option: course.course_options)
        .status
    end
  end

  def mapped_ucas_status
    return if dfe_scheme?

    if @matching_data['Rejects'] == '1'
      'rejected'
    elsif @matching_data['Withdrawns'] == '1'
      'withdrawn'
    elsif @matching_data['Declined offers'] == '1'
      'declined'
    elsif @matching_data['Offers'] == '1'
      'offer'
    else
      'awaiting_provider_decision'
    end
  end

  def accepted_on_apply?
    ApplicationStateChange::ACCEPTED_STATES.include?(status.to_sym)
  end

  def unwithdrawn_from_ucas?
    return false if dfe_scheme?

    !ApplicationStateChange::UNSUCCESSFUL_END_STATES.include?(mapped_ucas_status)
  end
end
