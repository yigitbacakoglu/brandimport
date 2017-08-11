class AirFormBuilder < SimpleForm::FormBuilder
  map_type :string, to: SmartStringInput
  map_type :text, to: SmartTextInput
  # https://github.com/plataformatec/simple_form/blob/master/lib/simple_form/form_builder.rb
  def input(attribute_name, options = {}, &block)
    if options[:placeholder].nil?
      options[:placeholder] ||= if object.class.respond_to?(:human_attribute_name)
        object.class.human_attribute_name(attribute_name.to_s)
      else
        attribute_name.to_s.humanize
      end
    end
    options[:label] = false if options[:label].nil?
    super
  end
end