# frozen_string_literal: true
class DistributionRule < ApplicationRecord

  # associations
  belongs_to :offering
  belongs_to :dynamic_property
  belongs_to :receiver, class_name: 'User'
  # has_many :values, class_name: 'DistributionValue'
  # constants
  OPERATORS = {
    'equal_to' => 'es igual a',
    'not_equal_to' => 'no es igual a',
    'greater_than' => 'es mayor que',
    'greater_than_or_equal_to' => 'es mayor o igual que',
    'less_than' => 'es menor que',
    'less_than_or_equal_to' => 'es menor o igual que',
    'in' => 'está en la lista',
    'not_in' => 'no está en la lista',
    # "in_range" => "está en un rango",
    # "not_in_range" => "no está en un rango",
    # "similar_to" => "es similar a",
    # "not_similar_to" => "no es similar a",
    'matches_regular_expression' => 'tiene el formato'
  }.freeze
  # scopes
  default_scope ->{ order(:priority) }
  # callbacks
  before_save :define_mixed_attribute, :define_priority

  class << self

    def receiver_for_lead(lead)
      lead.offering.distribution_rules.each do |rule|
        return rule.receiver if rule.matches?(lead)
      end
      nil
    end

    def recreate_priorities
      all.each_with_index do |r, i|
        r.priority = i + 1
        r.save
      end
    end

  end

  def define_mixed_attribute
    if dynamic_property_id.present? || dynamic_property.present?
      self.static_attribute = nil
    else
      self.dynamic_property_id = nil
    end
  end

  def define_priority
    self.priority ||= offering
      .distribution_rules
      .where.not(priority: nil)
      .count + 1
  end

  def prioritize
    define_priority
    return true if priority == 1

    offering
      .distribution_rules
      .where(priority: priority - 1)
      .update_all(priority:) # rubocop:disable Rails/SkipsModelValidations
    self.priority -= 1
    save
  end

  def deprioritize
    define_priority
    lower_rules = offering.distribution_rules.where(priority: priority + 1)
    return true if lower_rules.count.zero?

    lower_rules.where(priority: priority + 1).update_all(priority:) # rubocop:disable Rails/SkipsModelValidations
    self.priority += 1
    save
  end

  def mixed_attribute
    dynamic_property_id || static_attribute
  end

  def mixed_attribute=(att)
    if att.to_s =~ /^[0-9]+$/
      self.dynamic_property_id = att.to_i
    else
      self.static_attribute = att
    end
  end

  def attribute_description
    return dynamic_property.title if dynamic_property_id.present?

    Customer::STATIC_ATTRIBUTES[static_attribute] || Lead::HIDDEN_ATTRIBUTES.detect do |a|
      a[1] == static_attribute
    end[0]
  rescue StandardError
    nil
  end

  def matches?(lead)
    value_to_test = lead.value(mixed_attribute).to_s.strip
    compared_with = distribution_value
      .to_s
      .gsub(';', ',')
      .split(',')
      .map(&:strip)
    case comparison_operator
    when 'equal_to'
      return value_to_test == compared_with[0]
    when 'not_equal_to'
      return value_to_test != compared_with[0]
    when 'greater_than'
      return value_to_test > compared_with[0]
    when 'greater_than_or_equal_to'
      return value_to_test >= compared_with[0]
    when 'less_than'
      return value_to_test < compared_with[0]
    when 'less_than_or_equal_to'
      return value_to_test <= compared_with[0]
    when 'in'
      return value_to_test.in? compared_with
    when 'not_in'
      return !value_to_test.in?(compared_with)
    when 'in_range' # todo
    when 'not_in_range' # todo
    when 'similar_to' # todo
    when 'not_similar_to' # todo
    when 'matches_regular_expression'
      begin
        return value_to_test =~ Regexp.new(compared_with[0])
      rescue StandardError
        false
      end
    end
    false
  end

end
