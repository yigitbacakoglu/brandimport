module ActiveModel
  module V08
    # https://github.com/rails-api/active_model_serializers/blob/v0.10.4/docs/howto/upgrade_from_0_8_to_0_10.md
    class CollectionSerializer < ActiveModel::Serializer::CollectionSerializer
      # In AMS 0.8, passing an ArraySerializer instance with a `root` option
      # properly nested the serialized resources within the given root.
      # Ex.
      #
      # class MyController < ActionController::Base
      #   def index
      #     render json: ActiveModel::Serializer::ArraySerializer
      #       .new(resources, root: "resources")
      #   end
      # end
      #
      # Produced
      #
      # {
      #   "resources": [
      #     <serialized_resource>,
      #     ...
      #   ]
      # }
      def as_json(options = {})
        if root
          {
              root => super
          }
        else
          super
        end
      end

      # AMS 0.8 used `DefaultSerializer` if it couldn't find a serializer for
      # the given resource. When not using an adapter, this is not true in
      # `0.10`
      def serializer_from_resource(resource, serializer_context_class, options)
        serializer_class =
            options.fetch(:serializer) { serializer_context_class.serializer_for(resource) }

        if serializer_class.nil? # rubocop:disable Style/GuardClause
          DefaultSerializer.new(resource, options)
        else
          serializer_class.new(resource, options.except(:serializer))
        end
      end

      class DefaultSerializer
        attr_reader :object, :options

        def initialize(object, options={})
          @object, @options = object, options
        end

        def serializable_hash
          @object.as_json(@options)
        end
      end
    end
  end
end