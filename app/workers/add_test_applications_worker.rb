class AddTestApplicationsWorker
  include Sidekiq::Worker

  def perform
    return unless HostingEnvironment.environment_name.in?(%w[qa development])

    GenerateTestApplications.new.generate
  end
end
