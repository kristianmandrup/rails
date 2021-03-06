module ActiveRecord
  module AttributeMethods
    module PrimaryKey
      extend ActiveSupport::Concern

      # Returns this record's primary key value wrapped in an Array or nil if
      # the record is not persisted? or has just been destroyed.
      def to_key
        key = send(self.class.primary_key)
        [key] if key
      end

      module ClassMethods
        # Defines the primary key field -- can be overridden in subclasses. Overwriting will negate any effect of the
        # primary_key_prefix_type setting, though.
        def primary_key
          reset_primary_key
        end

        def reset_primary_key #:nodoc:
          key = get_primary_key(base_class.name)
          set_primary_key(key)
          key
        end

        def get_primary_key(base_name) #:nodoc:
          return 'id' unless base_name && !base_name.blank?

          case primary_key_prefix_type
          when :table_name
            base_name.foreign_key(false)
          when :table_name_with_underscore
            base_name.foreign_key
          else
            if ActiveRecord::Base != self && connection.table_exists?(table_name)
              connection.primary_key(table_name)
            else
              'id'
            end
          end
        end

        # Sets the name of the primary key column to use to the given value,
        # or (if the value is nil or false) to the value returned by the given
        # block.
        #
        #   class Project < ActiveRecord::Base
        #     set_primary_key "sysid"
        #   end
        def set_primary_key(value = nil, &block)
          define_attr_method :primary_key, value, &block
        end
        alias :primary_key= :set_primary_key
      end
    end
  end
end
