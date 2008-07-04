require 'rake'
require 'libs/genesis'

task :default do
  puts 'Type "rake --tasks" to see a list of tasks you can perform.'
end

# Load the Autumn environment.
task :environment do
  AL_ROOT = File.dirname(__FILE__)
  @genesis = Autumn::Genesis.new
  @genesis.load_global_settings
  @genesis.load_season_settings
end

task :full_bootstrap do
  AL_ROOT = File.dirname(__FILE__)
  @genesis = Autumn::Genesis.new
  @genesis.boot! false
end

namespace :app do
  desc "Launch the Autumn daemon"
  task :start do
    system 'script/daemon start'
  end
  
  desc "Stop the Autumn daemon"
  task :stop do
    system 'script/daemon stop'
  end
  
  desc "Restart the Autumn daemon"
  task :restart do
    system 'script/daemon restart'
  end
  
  desc "Start Autumn but not as a daemon (stay on top)"
  task :run do
    system 'script/daemon run'
  end
  
  desc "Force the daemon to a stopped state (clears PID files)"
  task :zap do
    system 'script/daemon zap'
  end
end

namespace :log do
  desc "Remove all log files"
  task :clear do
    system 'rm -vf tmp/*.log tmp/*.output log/*.log*'
  end
  
  desc "Print all error messages in the log files"
  task :errors => :environment do
    season_log = "log/#{@genesis.config.global :season}.log"
    system_log = 'tmp/autumn-leaves.log'
    if File.exists? season_log then
      puts "==== ERROR-LEVEL LOG MESSAGES ===="
      File.open(season_log, 'r') do |log|
        puts log.grep(/^[EF],/)
      end
    end
    if File.exists? system_log then
      puts "====   UNCAUGHT EXCEPTIONS    ===="
      File.open(system_log, 'r') do |log|
        puts log.grep(/^[EF],/)
      end
    end
  end
end

def local_db?(db)
  db.host.nil? or db.host == 'localhost'
end

namespace :db do
  desc "Create or update database tables according to the model objects"
  task :migrate => :full_bootstrap do
    lname = ENV['LEAF']
    raise "Usage: LEAF=[Leaf name] rake db:migrate" unless lname
    raise "Unknown leaf #{lname}" unless leaf = Autumn::Foliater.instance.leaves[lname]
    
    leaf.options[:module].constants.each do |cname|
      model = leaf.options[:module].const_get(cname.to_sym)
      next unless model.ancestors.include? DataMapper::Resource
      puts "Creating table for #{model}..."
      model.auto_migrate! leaf.database_name
    end
  end
  
  desc "Drop, recreates, and repopulates a database"
  task :reset => [ 'db:drop', 'db:create', 'db:populate' ]
end

namespace :doc do
  desc "Generate API documentation for Autumn"
  task :api => [ :environment, :clear ] do
    system 'rm -rf doc/api' if File.directory? 'doc/api'
    system "rdoc --main README --title 'Autumn API Documentation' -o doc/api --line-numbers --inline-source libs README"
  end
  
  desc "Generate documentation for all leaves"
  task :leaves => [ :environment, :clear ] do
    system 'rm -rf doc/leaves' if File.directory? 'doc/leaves'
    system "rdoc --main README --title 'Autumn Leaves Documentation' -o doc/leaves --line-numbers --inline-source leaves support"
  end
  
  desc "Remove all documentation"
  task :clear => :environment do
    system 'rm -rf doc/api' if File.directory? 'doc/api'
    system 'rm -rf doc/leaves' if File.directory? 'doc/leaves'
  end
end

# Load any custom Rake tasks in the bot's tasks directory.
Dir["leaves/*"].each do |leaf|
  leaf_name = File.basename(leaf, ".rb").downcase
  namespace leaf_name.to_sym do # Tasks are placed in a namespace named after the leaf
    FileList["leaves/#{leaf_name}/tasks/**/*.rake"].sort.each do |task|
      load task
    end
  end
end
