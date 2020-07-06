module ProviderInterface
  class SortApplicationChoices
    def self.call(application_choices:, sort_by:)
      application_choices.order(sort_order(sort_by))
    end

    def self.sort_by_attribute(sort_by)
      sort_by == 'Days left to respond' ? :reject_by_default_at : :updated_at
    end

    def self.sort_order(sort_by)
      return { updated_at: :desc } if sort_by != 'Days left to respond'

      Arel.sql(
        <<-ORDER_BY.strip_heredoc,
        (
          CASE
            WHEN (status='awaiting_provider_decision' AND (DATE(reject_by_default_at) > NOW())) THEN 1
            ELSE 0
          END
        ) DESC,
        reject_by_default_at ASC,
        application_choices.updated_at DESC
        ORDER_BY
      )
    end
  end
end
