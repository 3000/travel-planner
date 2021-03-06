module Travels
  class Trip < ActiveRecord::Base

    include Concerns::Copyable

    extend Dragonfly::Model
    extend Dragonfly::Model::Validations

    module StatusCodes
      DRAFT = '0_draft'
      PLANNED = '1_planned'
      FINISHED = '2_finished'

      ALL = [DRAFT, PLANNED, FINISHED]
      OPTIONS = ALL.map{|type| [I18n.t("common.#{type}"), type] }
      TYPE_TO_TEXT = {
          DRAFT => I18n.t("common.#{DRAFT}"),
          PLANNED => I18n.t("common.#{PLANNED}"),
          FINISHED => I18n.t("common.#{FINISHED}")
      }
    end

    paginates_per 9

    has_and_belongs_to_many :users, class_name: 'User', inverse_of: :trips, join_table: 'users_trips'
    belongs_to :author_user, class_name: 'User', inverse_of: :authored_trips

    has_many :days, class_name: 'Travels::Day'

    dragonfly_accessor :image
    def image_url_or_default
      self.image.try(:remote_url) || 'https://s3.amazonaws.com/altmer-cdn/images/no-image.png'
    end

    def status_text
      StatusCodes::TYPE_TO_TEXT[status_code]
    end

    validates_presence_of :name, :start_date, :end_date, :author_user_id

    validates :start_date, date: { before: :end_date, message: I18n.t('errors.date_before')  }
    validates :end_date, date: {before: Proc.new {|record| record.start_date + 30.days},
                                message: I18n.t('errors.end_date_days', period: 30)}

    validates_size_of :image, maximum: 10.megabytes, message: "should be no more than 10 MB", if: :image_changed?

    validates_property :format, of: :image, in: [:jpeg, :jpg, :png, :bmp], case_sensitive: false,
                          message: "should be either .jpeg, .jpg, .png, .bmp", if: :image_changed?

    default_scope ->{where(:archived => false)}

    after_save :update_plan

    def update_plan
      self.days ||= []
      days_count = (self.end_date - self.start_date).to_i + 1
      self.days.each_with_index do |day, index|
        day.date_when = (self.start_date + index.days)
        day.save
      end
      (days_count - self.days.length).times do
        date = self.days.last.try(:date_when)
        if date.blank?
          date = self.start_date
        else
          date = date + 1.day
        end
        self.days.create(date_when: date)
      end

      (self.days[days_count..-1] || []).each { |day| day.destroy }
    end

    def include_user(user)
      self.users.include?(user)
    end

    # private tasks can't be seen or cloned by user not participating in trip
    def can_be_seen_by? user
      !self.private || self.include_user(user)
    end

    def author
      author_user
    end

    def days_count
      (end_date - start_date + 1).to_i
    end

    def name_for_file
      name[0, 50].gsub(/[^0-9A-zА-Яа-яёЁ.\-]/, '_')
    end

    def last_non_empty_day_index
      result = -1
      (days || []).each_with_index { |day, index| result = index unless day.is_empty? }
      return result
    end

    def period
      ((end_date - start_date) unless start_date.blank? or end_date.blank?) || 1
    end

    def budget_sum
      result = 0
      (days || []).each do |day|
        result += (day.hotel.price || 0)
        (day.transfers || []).each {|transfer| result += (transfer.price || 0)}
        (day.activities || []).each {|activity| result += (activity.price || 0)}
        (day.expenses || []).each {|expense| result += (expense.price || 0)}
      end
      result
    end

    def copy trip
      super
      self.name += " (#{I18n.t('common.copy')})" unless self.name.blank?
      self
    end

    def copied_fields
      [:name, :start_date, :end_date]
    end

    def as_json(**args)
      attrs = {}
      ['id', 'comment', 'start_date', 'end_date', 'name', 'short_description',
        'archived', 'private', 'budget_for'].each do |field|
        attrs[field] = self.send(field)
      end
      attrs['id'] = attrs['id'].to_s
      attrs
    end

  end
end