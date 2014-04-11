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