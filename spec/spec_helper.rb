require "prime_service"
require "pry"

require "active_record"
require "database_cleaner"
require "fileutils"
require "sqlite3"

FIXTURES_PATH = File.join(__dir__, "fixtures")

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #config.order = 'random'

  I18n.enforce_available_locales = false


  config.before :suite do
    FileUtils.cp "#{FIXTURES_PATH}/template.sqlite3", "test.sqlite3"
    ActiveRecord::Base.establish_connection adapter:  "sqlite3",
                                            database: "test.sqlite3"
  end

  config.before :each, :database do
    DatabaseCleaner.start
  end

  config.after :each, :database do
    DatabaseCleaner.clean
  end

  config.after :suite do
    ActiveRecord::Base.connection.close
    FileUtils.rm "test.sqlite3"
  end
end
