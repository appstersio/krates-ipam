

task :environment do
  begin
    require 'dotenv'
    Dotenv.load
  rescue LoadError
  end
end
