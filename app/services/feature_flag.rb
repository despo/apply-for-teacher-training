class FeatureFlag
  attr_accessor :name, :description, :owner

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  def feature
    Feature.find_or_initialize_by(name: name)
  end

  PERMANENT_SETTINGS = [
    [:banner_about_problems_with_dfe_sign_in, 'Displays a banner to notify users that DfE-Sign is having problems', 'Jake Benilov'],
    [:banner_for_ucas_downtime, 'Displays a banner to notify users that UCAS is having problems', 'Theodor Vararu'],
    [:dfe_sign_in_fallback, 'Use this when DfE Sign-in is down', 'Tijmen Brommet'],
    [:force_ok_computer_to_fail, 'OK Computer implements a health check endpoint, this flag forces it to fail for testing purposes', 'Michael Nacos'],
    [:pilot_open, 'Enables the Apply for Teacher Training service', 'Tijmen Brommet'],
    [:getting_ready_for_next_cycle_banner, 'Displays an information banner related to the end-of-cycle with link to static page', 'Steve Hook'],
    [:deadline_notices, 'Show candidates copy related to end of cycle deadlines', 'Malcolm Baig'],
    [:hold_courses_open, 'Force all courses to appear to have vacancies. Do not enable in production!', 'Duncan Brown'],
    [:vendor_api_request_tracing, 'Enable middleware which records vendor API requests', 'Steve Laing'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:providers_can_filter_by_recruitment_cycle, 'Allows provider users to filter applications by recruitment cycle', 'Michael Nacos'],
    [:international_addresses, 'Candidates who live outside the UK can enter their local address in free-text format', 'Steve Hook'],
    [:international_personal_details, 'Changes to the candidate personal details section to account for international applicants.', 'David Gisbey'],
    [:efl_section, 'Allow candidates with nationalities other then British or Irish to specify their English as a Foreign Language experience', 'Malcolm Baig'],
    [:international_degrees, 'Changes to the model and forms for degree qualifications to cater for non-UK degrees.', 'Steve Hook'],
    [:international_gcses, 'Candidates can provide details of international GCSE equivalents.', 'George Holborn'],
    [:international_other_qualifications, 'Candidates can provide details of Other international qualifications .', 'David Gisbey'],
    [:export_hesa_data, 'Providers can export applications including HESA data.', 'Steve Laing'],
    [:feedback_form, 'New simplified feedback form to replace old multi-page satisfaction survey.', 'Steve Hook'],
    [:feedback_prompts, 'Candidates can give feeback while completing their application form', 'David Gisbey'],
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).map { |name, description, owner|
    [name, FeatureFlag.new(name: name, description: description, owner: owner)]
  }.to_h.with_indifferent_access.freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    FEATURES[feature_name].feature.active?
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
  end
end
