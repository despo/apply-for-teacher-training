class GenerateTestData
  def initialize(number_of_candidates, provider = nil)
    @number_of_candidates = number_of_candidates
    @provider = provider || fake_provider
  end

  def generate
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    # delete_all doesn't work on `through` associations
    provider.application_choices.map(&:delete)

    number_of_candidates.times do
      first_name = Faker::Name.unique.first_name
      last_name = Faker::Name.unique.last_name
      candidate = FactoryBot.create(
        :candidate,
        email_address: "#{first_name.downcase}.#{last_name.downcase}@example.com",
      )

      # Most of the time generate an application with a single course choice,
      Audited.audit_class.as_user(candidate) do
        traits = [:with_completed_references]
        traits << :with_equality_and_diversity_data if rand < 0.55
        application_form = FactoryBot.create(
          :completed_application_form,
          *traits,
          application_choices_count: 0,
          candidate: candidate,
          first_name: first_name,
          last_name: last_name,
        )

        # Most of the time generate an application with a single course choice,
        # and sometimes 2 or 3.
        [1, 1, 1, 1, 1, 1, 1, 2, 3].sample.times do
          FactoryBot.create(
            :application_choice,
            :awaiting_provider_decision,
            course_option: course_option,
            application_form: application_form,
          )
        end
      end
    end
  end

private

  attr_reader :provider, :number_of_candidates

  def course_option
    FactoryBot.create(
      :course_option,
      course: random_course,
      site: random_site,
    )
  end

  def random_course
    FactoryBot.create(
      :course,
      provider: provider,
      code: random_code(Course, provider, Course::CODE_LENGTH),
    )
  end

  def random_site
    return Site.where(provider: provider).sample if Site.where(provider: provider).count > 10

    FactoryBot.create(
      :site,
      provider: provider,
      code: random_code(Site, provider, Site::CODE_LENGTH),
    )
  end

  def fake_provider
    Provider.find_or_create_by(code: 'ABC') do |provider|
      provider.name = 'Example Training Provider'
    end
  end

  def random_code(klass, provider, code_length)
    loop do
      code = Faker::Alphanumeric.alphanumeric(number: code_length).upcase
      return code if klass.find_by(code: code, provider: provider).nil?
    end
  end
end
