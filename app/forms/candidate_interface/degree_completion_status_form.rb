module CandidateInterface
  class DegreeCompletionStatusForm
    include ActiveModel::Model

    attr_accessor :degree_completed

    validates :degree_completed, presence: true

    def save(degree)
      return false unless valid?

      degree.update!(predicted_grade: grade_is_predicted?)
    end

    def fill(degree)
      self.degree_completed = degree.completed? ? 'yes' : 'no'
      self
    end

  private

    def grade_is_predicted?
      degree_completed == 'no'
    end
  end
end
