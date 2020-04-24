require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  every(1.minute, 'ClockworkCheck') { ClockworkCheck.perform_async }
  every(1.minute, 'HealthCheck') { HealthCheckWorker.perform_async }
  every(15.minutes, 'SyncAllFromFind') { SyncAllFromFind.perform_async }
  every(1.hour, 'DetectInvariants') { DetectInvariants.perform_async }
  every(1.hour, 'SendApplicationsToProvider', at: '**:05') { SendApplicationsToProviderWorker.perform_async }
  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }
  every(1.hour, 'SendChaseEmailToReferees', at: '**:20') { SendChaseEmailToRefereesWorker.perform_async }
  every(1.hour, 'SendChaseEmailToProviders', at: '**:25') { SendChaseEmailToProvidersWorker.perform_async }
  every(1.hour, 'AskCandidatesForNewReferees', at: '**:30') { AskCandidatesForNewRefereesWorker.perform_async }
  every(1.hour, 'SendChaseEmailToCandidates', at: '**:35') { SendChaseEmailToCandidatesWorker.perform_async }
  every(1.day, 'DailyReport', at: '08:00', if: lambda { |_| Time.zone.today.weekday? }) { DailyReport.perform_async }
end
