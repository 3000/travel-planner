module Geo
  class Country < ActiveRecord::Base

    include Concerns::Geographical

    def load_additional_info(str)
      values = Geo::Country.split_geonames_string(str)
      update_attributes(
          iso_code: values[0].strip,
          iso3_code: values[1].strip,
          iso_numeric_code: values[2].strip,
          area: values[6].strip,
          continent: values[8].strip,
          currency_code: values[10].strip,
          currency_text: values[11].strip,
          languages: values[15].strip.split(/,/)
      )
    end

  end
end