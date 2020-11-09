require 'rails_helper'

RSpec.describe CandidateInterface::DegreeCompletionStatusForm, type: :model do
  it 'validates presence of degree_completed' do
    form = described_class.new
    expect(form).not_to be_valid
    expect(form.errors.full_messages).to include 'Degree completed Select if you have completed your degree or not'
  end

  describe '#save(degree)' do
    it 'sets degree.predicted_grade to true if the degree_completed attr is "no"' do
      degree = build(:degree_qualification, predicted_grade: nil)
      form = described_class.new(degree_completed: 'no')

      form.save(degree)

      expect(degree.reload.predicted_grade).to eq true
    end

    it 'sets degree.predicted_grade to false if the degree_completed attr is "yes"' do
      degree = build(:degree_qualification, predicted_grade: nil)
      form = described_class.new(degree_completed: 'yes')

      form.save(degree)

      expect(degree.reload.predicted_grade).to eq false
    end
  end

  describe '#fill(degree)' do
    it 'sets degree_completed to "no" if degree.completed? is false' do
      degree = instance_double(ApplicationQualification, completed?: false)
      form = described_class.new
      form.fill(degree)

      expect(form.degree_completed).to eq 'no'
    end

    it 'sets degree_completed to "yes" if degree.completed? is true' do
      degree = instance_double(ApplicationQualification, completed?: true)
      form = described_class.new
      form.fill(degree)

      expect(form.degree_completed).to eq 'yes'
    end
  end
end
