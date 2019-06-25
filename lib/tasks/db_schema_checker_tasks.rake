namespace :db do
  namespace :migrate do
    namespace :reset do
      desc 'Check the consistency of schema.rb'
      task :check do
        unless Rails.env.test?
          abort 'This task must be run under test environment'
        end

        original_env_schema = ENV['SCHEMA']
        original_env_verbose = ENV['VERBOSE']

        consistent = nil
        diffs = nil
        Dir.mktmpdir(nil, Rails.root.join('tmp')) do |dir|
          schema_rb = Rails.root.join('db', 'schema.rb')
          generated_schema = File.join(dir, 'schema.rb')

          ENV['SCHEMA'] = generated_schema
          ENV['VERBOSE'] = 'false'

          Rake::Task['db:migrate:reset'].invoke

          consistent = FileUtils.compare_file(schema_rb, generated_schema)
          diffs = Diff::LCS.diff(File.read(schema_rb), File.read(generated_schema)) unless consistent
        end

        ENV['SCHEMA'] = original_env_schema
        ENV['VERBOSE'] = original_env_verbose

        if consistent
          puts 'ok'
          exit 0
        else
          puts 'ERROR: Generated schema is not consistent with db/schema.rb'
          diffs.each do |diff|
            puts diff
          end
          exit 1
        end
      end
    end
  end
end
