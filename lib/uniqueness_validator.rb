class UniquenessValidator < ActiveModel::EachValidator
  def initialize(options)
    @scope = options[:scope]
    super
  end


  def validate_each(record, attribute, value)
    relation = record.send("model_for_#{attribute}").class
                 .where(attribute => value)

    Array(@scope).each do |scope|
      relation = relation.where(scope => record.send(scope))
    end

    if relation.any?
      record.errors.add attribute, :taken
    end
  end
end
