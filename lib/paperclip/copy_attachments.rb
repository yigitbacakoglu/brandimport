### s3 implementation of Paperclip module that supports deep
### cloning of objects by copying image attachments.
### Refer to Paperclip issue: https://github.com/thoughtbot/paperclip/issues/1361#issuecomment-39684643
### Original gist works with fog: https://gist.github.com/stereoscott/10011887

module Paperclip
  module CopyAttachments
    def copy_attachments_from(source_obj, source_bucket = nil, destination_bucket = nil)
      self.class.attachment_definitions.keys.each do |attachment_name|
        source_attachment      = source_obj.send(attachment_name)
        destination_attachment = self.send(attachment_name)

        next unless source_attachment.present?

        if source_attachment.options[:storage] != :s3
          self.send("#{attachment_name}=", source_attachment)
          next
        end


        source_bucket      ||= bucket source_attachment
        destination_bucket ||= bucket destination_attachment

        [:original, *destination_attachment.styles.keys].uniq.map do |style|
          source_path      = path(source_attachment, style)
          destination_path = path(destination_attachment, style)

          Paperclip.log("Copying #{style} from #{source_bucket}/#{source_path} ---> #{destination_bucket}/#{destination_path}")
          begin
            copy_object(source_bucket, source_path, destination_bucket, destination_path)
          rescue Excon::Errors::NotFound
            Paperclip.log("Could not find #{style} from #{source_bucket}/#{source_path}")
          end
        end
      end
    end

    private

    def path(attachment, style)
      path = attachment.path(style)
      path.slice!(0) if path.start_with? '/'
      path
    end

    def bucket(attachment)
      s3_coordinator.bucket attachment.bucket_name
    end

    def s3_coordinator
      @s3_coordinator ||= Paperclip::S3Coordinator.new
    end

    def copy_object(source_bucket, source_path, destination_bucket, destination_path)
      s3_coordinator.copy(from_bucket: source_bucket,
          from_path: source_path,
          to_bucket: destination_bucket,
          to_path: destination_path,
          options: {acl: :public_read})
    end
  end
end