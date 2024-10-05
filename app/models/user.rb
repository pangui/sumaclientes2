# frozen_string_literal: true
class User < ApplicationRecord

  # associations
  belongs_to :merchant
  has_many :permissions, dependent: :restrict_with_exception
  # settings
  devise \
    :database_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable
  # accessors
  attr_accessor :website, :permission_keys
  # scopes
  scope :active, ->{ where(active: true) }
  scope :deleted, ->{ where(active: false) }
  scope :not_admins, ->{ where(admin: false) }
  # callbacks
  before_save :save_permissions

  def save_permissions
    return true if @permission_keys.nil?

    @permission_keys = @permission_keys.reject{|p| p.to_s == '-1' }
    # delete permissions not included in @permission_keys
    to_delete = permissions.pluck(:key) - @permission_keys
    permissions.where(key: to_delete).destroy_all
    # add permissions included in @permission_keys
    to_add = @permission_keys - permissions.pluck(:key)
    to_add.each{|p| permissions << Permission.new(key: p) }
  end

  def soft_delete
    self.deleted = true
    save
  end

end
