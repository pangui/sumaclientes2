# frozen_string_literal: true
class LeadStatusGroup < ApplicationRecord

  # associations
  belongs_to :offering
  # callbacks
  before_save :assign_sort_index
  # scopes
  default_scope ->{ order(:sort_index) }

  def assign_sort_index
    self.sort_index ||= offering.statuses.map(&:sort_index).map(&:to_i).max.to_i + 1
  end

  def up
    previous_group = offering.status_groups.detect{|e| e.sort_index == (sort_index - 1) }
    return false if previous_group.nil?

    indexes = [sort_index, previous_group.sort_index]
    self.sort_index = indexes[1]
    previous_group.sort_index = indexes[0]
    previous_group.save
    save
  end

  def down
    next_group = offering.status_groups.detect{|e| e.sort_index == (sort_index + 1) }
    return false if next_group.nil?

    indexes = [sort_index, next_group.sort_index]
    self.sort_index = indexes[1]
    next_group.sort_index = indexes[0]
    next_group.save
    save
  end

end
