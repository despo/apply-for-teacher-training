class UCASMatchedApplication
  def initialize(matching_data, recruitment_cycle_year)
    @matching_data = matching_data
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def course
    Course.find_by(
      code: @matching_data['Course code'],
      provider: Provider.find_by(code: @matching_data['Provider code']),
      recruitment_cycle_year: @recruitment_cycle_year,
    )
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
      ApplicationChoice.includes(:application_form)
        .where('application_forms.candidate_id = ?', @matching_data['Apply candidate ID']).references(:application_forms)
        .find_by(course_option: course.course_options)
        .status
    end
  end

  def mapped_ucas_status
    if @matching_data['Rejects'] == '1'
      'rejected'
    elsif @matching_data['Withdrawns'] == '1'
      'withdrawn'
    elsif @matching_data['Declined offers'] == '1'
      'declined'
    elsif @matching_data['Conditional firm'] == '1'
      'pending_conditions'
    elsif @matching_data['Unconditional firm'] == '1'
      'recruited'
    elsif @matching_data['Offers'] == '1'
      'offer'
    else
      'awaiting_provider_decision'
    end
  end
end
