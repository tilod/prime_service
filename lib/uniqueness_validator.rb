class UniquenessValidator < ActiveModel::EachValidator
  def initialize(options)
    @scope      = options[:scope]
    @conditions = options[:conditions]
    super
  end


  def validate_each(record, attribute, value)
    relation = record.send("model_for_#{attribute}").class
                 .where(attribute => value)

    Array(@scope).each do |scope|
      relation = relation.where(scope => record.send(scope))
    end

    if @conditions
      relation = relation.merge(@conditions)
    end

    count     = relation.count
    conflicts = count > 1 || (count == 1 && relation.first.id != record.id)
    if conflicts
      record.errors.add attribute, :taken
    end
  end
end
