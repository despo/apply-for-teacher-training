class RejectionReasonsForm
  include ActiveModel::Model

  QUESTIONS = [
    RejectionReasonQuestion.new(
      label: 'Was it related to candidate behaviour?',
      reasons: [
        RejectionReasonReason.new(label: 'Didn’t reply to our interview offer'),
        RejectionReasonReason.new(label: 'Didn’t attend interview'),
        RejectionReasonReason.new(label: 'Other'),
      ],
    ),
    RejectionReasonQuestion.new(
      label: 'Was it related to the quality of their application?',
      reasons: [
        RejectionReasonReason.new(label: 'Personal statement'),
        RejectionReasonReason.new(label: 'Subject knowledge'),
        RejectionReasonReason.new(label: 'Other'),
      ],
    ),
    RejectionReasonQuestion.new(
      label: 'QUESTION3',
      reasons: [
        RejectionReasonReason.new(label: 'Reason1'),
        RejectionReasonReason.new(label: 'Reason2'),
      ],
    ),
  ]

  attr_writer :questions
  validate :questions_all_valid?

  def questions
    @questions || []
  end

  def answered_questions
    @answered_questions || []
  end

  def next_step!
    @answered_questions = answered_questions + questions
    if @answered_questions.count == 0
      @questions = QUESTIONS.take(2)
    elsif @answered_questions.count == 2 # or whatever
      @questions = QUESTIONS.drop(2)
    else # no further questions
      @questions.clear
    end
  end

  alias_method :begin!, :next_step!

  def done?
    @answered_questions.any? && @questions.empty?
  end

  def questions_all_valid?
    questions.each_with_index do |q, i|
      next unless q.invalid?

      q.errors.each do |attr, message|
        errors.add("questions[#{i}].#{attr}", message)
      end
    end
  end

  def questions_attributes=(attributes)
    @questions ||= []
    attributes.each do |_id, q|
      @questions.push(RejectionReasonQuestion.new(q))
    end
  end
end
