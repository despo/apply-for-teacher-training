class PerformanceStatistics
  CANDIDATE_QUERY = "
  WITH raw_data AS (
      SELECT
          c.id,
          date_part('year', c.created_at) AS sign_up_year,
          date_part('week', c.created_at) AS sign_up_week,
          f.id,
          COUNT(f.id) FILTER (WHERE f.id IS NOT NULL) application_forms,
          COUNT(ch.id) FILTER (WHERE f.id IS NOT NULL) application_choices,
          CASE
            WHEN f.id IS NULL THEN ARRAY['-1', 'never_signed_in']
            WHEN ARRAY_AGG(DISTINCT ch.status) IN ('{NULL}', '{unsubmitted}') AND DATE_TRUNC('second', f.updated_at) = DATE_TRUNC('second', f.created_at) THEN ARRAY['0', 'unsubmitted_not_started_form']
            WHEN ARRAY_AGG(DISTINCT ch.status) IN ('{NULL}', '{unsubmitted}') AND DATE_TRUNC('second', f.updated_at) <> DATE_TRUNC('second', f.created_at) THEN ARRAY['1', 'unsubmitted_in_progress']
            WHEN 'awaiting_references' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['2', 'awaiting_references']
            WHEN 'application_complete' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['3', 'waiting_to_be_sent']
            WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['4', 'awaiting_provider_decisions']
            WHEN 'offer' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['6', 'awaiting_candidate_response']
            WHEN 'enrolled' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['9', 'enrolled']
            WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['8', 'recruited']
            WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['7', 'pending_conditions']
            WHEN ARRAY_REMOVE(ARRAY_REMOVE(ARRAY_REMOVE(ARRAY_REMOVE(ARRAY_AGG(DISTINCT ch.status), 'withdrawn'), 'rejected'), 'declined'), 'conditions_not_met') = '{}' THEN ARRAY['5', 'ended_without_success']
            ELSE ARRAY['10', 'unknown_state']
          END status
      FROM
          application_forms f
      FULL OUTER JOIN
          candidates c ON f.candidate_id = c.id
      LEFT JOIN
          application_choices ch ON ch.application_form_id = f.id
      WHERE
          NOT c.hide_in_reporting
      GROUP BY
          c.id, f.id
  )
  SELECT
      sign_up_year,
      sign_up_week,
      raw_data.status[1] as ordering,
      raw_data.status[2] as status,
      COUNT(*)
  FROM
      raw_data
  GROUP BY
      raw_data.status,
      sign_up_year,
      sign_up_week
  ORDER BY
      sign_up_year,
      sign_up_week,
      raw_data.status[1]".freeze

  def [](key, opts = nil)
    if opts.present?
      candidate_status_counts
        .find { |x| x['status'] == key.to_s && x['sign_up_year'] == opts[:year] && x['sign_up_week'] == opts[:week] }
        &.[]('count') || 0
    else
      candidate_status_counts
        .select { |x| x['status'] == key.to_s }
        .map { |x| x['count'] }
        .sum
    end
  end

  def total_candidate_count(only: nil, except: [], in_year_and_week: nil)
    candidate_status_counts
     .select { |row| only.nil? || row['status'].to_sym.in?(only) }
     .select { |row| in_year_and_week.nil? || [row['sign_up_year'].to_i, row['sign_up_week'].to_i] == in_year_and_week }
     .reject { |row| row['status'].to_sym.in?(except) }
     .map { |row| row['count'] }
     .sum
  end

  def process_states
    candidate_status_counts
      .map { |row| [row['ordering'], row['status']] }
      .uniq
      .sort_by(&:first)
      .map(&:second)
  end

  def candidate_status_counts
    @candidate_status_counts ||= ActiveRecord::Base
      .connection
      .execute(CANDIDATE_QUERY)
      .to_a
  end

  def last_6_weeks_with_activity
    candidate_status_counts
      .map { |row| [row['sign_up_year'], row['sign_up_week']] }
      .uniq
      .sort
      .last(6)
  end
end
