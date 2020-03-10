class SummaryListComponent < ActionView::Component::Base
  validates :rows, presence: true

  def initialize(rows:)
    @rows = rows
  end

  def any_row_has_action_span?
    @rows.select { |row| row.has_key?(:action) || row.has_key?(:change_path) }.any?
  end

private

  attr_reader :rows
end
