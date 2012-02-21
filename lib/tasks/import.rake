desc 'Read shows from file & persist'
task import: :environment do
  Parse.run('shows.txt')
end
