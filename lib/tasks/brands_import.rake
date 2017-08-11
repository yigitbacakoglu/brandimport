namespace :air do

  desc "Import records from CSV files"
  namespace :import do


    desc "Import brands, assumes brands.csv in root"
    task brands: :environment do
      # BrandProfile.destroy_all
      # Brand.destroy_all
      require "csv_import"
      class ImportBrand < Brand
        self.table_name = :brands

        attr_accessor :tagline

        after_save do |record|
          # create a brand profile
          #brand_profile = BrandProfile.where(brand_id: record.id).first_or_initialize
          #brand_profile.user_id = record.user_id
          #brand_profile.name = record.name
          #brand_profile.idea = ""
          #brand_profile.overall_look = ""
          #brand_profile.your_brand = record.tagline
          #brand_profile.industry = [""]
          #brand_profile.save(validate: false)

          # create a job to fetch the images
          Resque.enqueue(ImportBrandImages, record.id)
        end
      end
      brand_tags = YAML.load_file(Rails.root.join("config", "brand_tags.yml"))

      csv_import = CSVImport.new(ENV.fetch("FILE", "brands.csv"),
        model: ImportBrand,
        identifiers: %w[id name folder],
        nice_header: "name"
      )
      csv_import.define_default("user_id", 6)
      csv_import.define_default("imported", true)
      csv_import.define_default("tagline", "") # transient on Brand
      csv_import.define_transform("tags") do |value, _|
        brand_tags.select { |tag| value.to_s.include?(tag) }
      end
      to_cents = ->(value, _) { value ? value.to_i * 100 : value }
      csv_import.define_transform("max_budget_cents", &to_cents)
      csv_import.define_transform("prices_from_cents", &to_cents)
      csv_import.define_transform("prices_to_cents", &to_cents)
      csv_import.define_transform("email") { |value, row| value.blank? ? row["secondary_email"] : value }
      to_bool = ->(value, _) { value =~ /yes/i ? true : (value =~ /no/i ? false : nil) }
      csv_import.define_transform("interested_collaborations", &to_bool)
      csv_import.define_transform("looking_for_space", &to_bool)
      csv_import.define_transform("created_at") { |value, _| Time.zone.parse(value) rescue Time.zone.now }
      csv_import.run
    end
  end

end
