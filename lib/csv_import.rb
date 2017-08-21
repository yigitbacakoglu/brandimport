class CSVImport

  attr_reader :path, :model, :identifiers, :csv_options
  attr_reader :defaults, :transformations, :nice_header

  def initialize(path, model:, identifiers: %w[id], col_sep: ";", :quote_char => "|", nice_header: nil)
    @path, @model = path, model
    @identifiers = identifiers
    @csv_options = { col_sep: col_sep, quote_char: quote_char, headers: true, skip_blanks: true }
    @defaults = {}
    @transformations = {}
    @nice_header = nice_header || headers.first
  end

  def import
    out << headers
    csv.each do |row|
      instance = scope_for(row, :and).first || scope_for(row, :or).first || model.new
      yield(row, instance) if block_given?
      common_columns.each do |column|
        value = row[column] || defaults[column]
        value = transform(column, value, row)
        instance.send(:"#{column}=", value)
        row[column] = value
        stats[:changes] += 1 if instance.respond_to?(:"#{column}_changed?") && instance.send(:"#{column}_changed?")
      end
      begin
        if instance.id.nil? && instance.save
          stats[:creates] += 1
        elsif instance.changed? && instance.save
          stats[:updates] += 1
        else
          instance.save(validate: false)
          stats[:invalid] += 1
        end
      rescue ActiveRecord::StatementInvalid => e
        case e.message
        when /value too long for type/
          puts "column too long: [#{row[nice_header]}] #{common_columns.select {|c| row[c].to_s.length > 255}}\n"
          stats[:value_too_long] += 1
        when /violates (.+) constraint/
          puts "contraint violation #{$1}: [#{row[nice_header]}]"
          stats[:error] += 1
        else
          raise e
        end
      end
      row["id"] = instance.id
      out << row
    end
  ensure
    out.flush
    out.close
    File.delete(out.path) rescue ''
  end

  def run
    puts "CSVImport #{path}"
    puts "  lines: #{lines}"
    puts "  unknown columns: #{headers - common_columns - %w[id]}"
    puts "  common columns: #{common_columns}"
    i = 0
    import { |row, instance| i += 1 }
    puts
    puts "stats"
    stats.each { |k, v| puts "  #{k}: #{v}" }
  end

  def scope_for(row, operator)
    arel = model.arel_table
    query = identifiers.inject(nil) do |result, column|
      eq = arel[column].eq(row[column])
      result ? result.send(operator, eq) : eq
    end
    model.where(query)
  end

  def define_default(column, value)
    @defaults[column] = value
  end

  def define_transform(column, &block)
    @transformations[column] = block
  end

  def transform(column, value, row)
    transformation = transformations[column]
    return value unless transformation.respond_to?(:call)
    new_value = transformation.call(value, row)
    stats[:transformations] += 1 if new_value != value
    new_value
  end

  def common_columns
    @common_columns ||= (model.column_names & headers) - %w[id]
    @common_columns + defaults.keys.map(&:to_s)
  end

  def headers
    @headers ||= csv.first.headers
  end

  def lines
    @lines ||= csv.count
  end

  def stats
    @stats ||= Hash.new(0)
  end

  private

  def csv
    @csv ||= CSV.new(File.open(path, "r"), **csv_options)
    @csv.rewind
    @csv
  end

  def out
    @out ||= CSV.open("#{path}.out.csv", "wb", **csv_options)
  end
end
