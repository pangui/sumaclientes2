# frozen_string_literal: true
exit(0) unless Rails.env.development?

chile = Area.create(
  name: 'Chile',
  country_code: 'cl',
  level: 1,
  code: 'cl'
)
[
  {
    level: 1,
    name: 'Región Metropolitana',
    code: '1113',
    provinces: [
      {
        level: 2,
        name: 'Santiago',
        code: '1123',
        communes: [
          {
            level: 3,
            name: 'Las Condes',
            code: '23412'
          }
        ]
      }
    ]
  }
].each do |region_data|
  provinces = region_data.delete(:provinces)
  region_data[:area_id] = chile.id
  region = Area.create(region_data)
  provinces.each do |province_data|
    communes = province_data.delete(:communes)
    province_data[:area_id] = region.id
    province = Area.create(province_data)
    communes.each do |commune_data|
      commune_data[:area_id] = province.id
      Area.create(commune_data)
    end
  end
end
