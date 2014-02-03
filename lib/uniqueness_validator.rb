class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.send("model_for_#{attribute}").class
        .where(attribute => value).any?
      record.errors.add attribute, :taken
    end
  end
end
