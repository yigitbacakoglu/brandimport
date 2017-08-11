# Code adapted from https://gist.github.com/rsmithlal/6427646845fbb8a882c3
module Paperclip
  class Watermark < Processor

    def initialize(file, options = {}, attachment = nil)
      super
      geometry = options[:geometry]
      @file = file
      @crop = geometry[-1,1] == '#'
      @target_geometry = Geometry.parse geometry
      @current_geometry = Geometry.from_file @file
      @convert_options = options[:convert_options]
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @format = options[:format]
      @watermark_path = options[:watermark_path]
      @position = options[:position].nil? ? "Center" : options[:position]
      @watermark_offset = options[:watermark_offset]
      @overlay = options[:overlay].nil? ? true : false
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
    end

     # Returns true if the +target_geometry+ is meant to crop.
    def crop?
      @crop
    end

    # Returns true if the image is meant to make use of additional convert options.
    def convert_options?
      not @convert_options.blank?
    end

    # Performs the conversion of the +file+ into a watermark. Returns the Tempfile
    # that contains the new image.
    def make
      dst = Tempfile.new([@basename].compact.join("."))
      dst.binmode

      command = "convert"
      params = ["'#{fromfile}'"]
      params += transformation_command
      params += watermark_command if @watermark_path
      params << "'#{tofile(dst)}'"

      begin
        Paperclip.run(command, params.join(' '))
      rescue ArgumentError, Cocaine::CommandLineError
        raise Paperclip::Error.new("There was an error processing the watermark for #{@basename}") if @whiny
      end

      dst
    end

    def transformation_command
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      trans = %W[-resize '#{scale}']
      trans += %W[-crop '#{crop}' +repage] if crop
      trans << @convert_options if @convert_options.present?
      trans
    end

    def watermark_command
      watermark = %W['#{@watermark_path}' -gravity #{@position}]
      watermark << "-geometry +#{@watermark_offset}+#{@watermark_offset}" if @watermark_offset
      watermark << "-composite"
    end

    def fromfile
      File.expand_path(@file.path)
    end

    def tofile(destination)
      File.expand_path(destination.path)
    end

  end
end
