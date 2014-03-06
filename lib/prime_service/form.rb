module PrimeService
  class Form < ::Reform::Form
    def submit(params = nil)
      if params ? validate(params) : valid?
        process
      else
        false
      end
    end


    def process
      save
    end
  end
end
