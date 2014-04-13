module Geo
  class City

    include Mongoid::Document
    include Concerns::Geographical

    module Statuses
      CAPITAL = 'capital'
      REGION_CENTER = 'region_center'
      DISTRICT_CENTER = 'district_center'
      ADM3_CENTER = 'adm3_center'
      ADM4_CENTER = 'adm4_center'
      ADM5_CENTER = 'adm5_center'
    end

    field :status, type: String

    field :country_text, type: String
    field :country_text_ru, type: String
    field :country_text_en, type: String

    field :region_text, type: String
    field :region_text_ru, type: String
    field :region_text_en, type: String

    field :denormalized, type: Boolean, default: false

    def country_translated_name(locale = I18n.locale)
      denormalize unless denormalized
      self.send("country_text_#{locale}") || country_text
    end

    def region_translated_name(locale = I18n.locale)
      denormalize unless denormalized
      self.send("region_text_#{locale}") || region_text
    end

    def denormalize
      self.country_text = self.country.try(:name)
      self.country_text_ru = self.country.try(:name_ru)
      self.country_text_en = self.country.try(:name_en)

      self.region_text = self.region.try(:name)
      self.region_text_ru = self.region.try(:name_ru)
      self.region_text_en = self.region.try(:name_en)

      self.denormalized = true
      self.save
    end

    def is_capital?
      status == Statuses::CAPITAL
    end

    def is_region_center?
      status == Statuses::REGION_CENTER
    end

    def is_district_center?
      status == Statuses::DISTRICT_CENTER
    end

    def is_adm3_center?
      status == Statuses::ADM3_CENTER
    end

    def is_adm4_center?
      status == Statuses::ADM4_CENTER
    end

    def is_adm5_center?
      status == Statuses::ADM5_CENTER
    end

    def update_from_geonames_string(str)
      super(str)
      values = Geo::City.split_geonames_string(str)
      feature_code = values[7].strip
      case feature_code
        when 'PPLC'
          self.status = Statuses::CAPITAL
        when 'PPLA'
          self.status = Statuses::REGION_CENTER
        when 'PPLA2'
          self.status = Statuses::DISTRICT_CENTER
        when 'PPLA3'
          self.status = Statuses::ADM3_CENTER
        when 'PPLA4'
          self.status = Statuses::ADM4_CENTER
      end
      save
    end

  end
end