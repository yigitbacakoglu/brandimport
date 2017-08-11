 class ImportBrand < Brand
    self.table_name = :brands

    attr_accessor :tagline

    after_save do |record|
      Resque.enqueue(ImportBrandImages, record.id)
    end
end