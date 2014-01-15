# write-once, read-many
# Allows a value to be set to a non-nil value once, and then makes it immutable.
# Combine with :existence=>true to accomplish the same thing as attr_readonly,
# except with error messages (instead of silently refusing to save the change).
# eg: validates :user_id, :write_once=>true
# 
# Can also be configured to ignore identical writes of the already set value,
# useful in blind-update operations.
# eg: validates :user_id, :write_once=>{:ignore_identical=>true}

module ActiveModel::Validations
  class WriteOnceValidator < ActiveModel::EachValidator
    # as of ActiveModel 4, :allow_nil=>true causes a change from a value back to
    #   nil to be allowed. prevent this.
    def validate(record)
      attributes.each do |attribute|
        value = record.read_attribute_for_validation(attribute)
        validate_each(record, attribute, value)
      end
    end

    def validate_each(record, attribute, value)
      ignore_identical = options[:ignore_identical] || false
      if record.persisted? && record.send("#{attribute}_changed?") && !record.send("#{attribute}_was").nil?
        # The attribute has changed from a non-nil to a non-nil
        if !ignore_identical || value == record.send("#{attribute}_was")
          record.errors.add(attribute, :unchangeable, options)
        end
      end
    end
  end
end
