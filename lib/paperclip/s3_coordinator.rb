module Paperclip
  class S3Coordinator

    def initialize
      @s3 = AWS::S3.new
    end

    def bucket(name)
      @s3.buckets[name]
    end

    def copy(from_bucket, from_path, to_bucket, to_path, options)
      from_bucket.objects[from_path].copy_to(to_bucket.objects[to_path], options)
    end

  end
end
