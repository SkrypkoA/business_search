require 'csv'
desc 'Seed businesses'
task :seed_businesses => :environment do
  CSV.foreach(Rails.root.join('lib/tasks/mock/MOCK_BIZ_DATA.csv').to_s, headers: true) do |row|
    Business.create(row.to_h)
  end
end
