require 'csv'
require 'tempfile'
require 'erb'
require 'ostruct'

namespace :csv do
  def csv_path
    Rails.root.join('db/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv')
  end

  def server_path
    Rails.root.join('db/neo4j', Rails.env)
  end

  def erb(template, vars)
    ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
  end

  task fix: :environment do
    path = csv_path

    tempfile = Tempfile.new('lapd.csv')

    header_processed = false
    CSV.open(tempfile.path, "wb") do |destination|
      CSV.foreach(path) do |row|
        new_row = if row[10,1] == ['UNK']
          putc '-'
          row[0,8] + row[10, 1] + row[8,2] + row[11..-1]
        elsif row[9,1] == ['UNK']
          putc '+'
          row
        elsif %w{IC AA AO JA JO UNK}.include?(row[10]) || !header_processed
          header_processed = true
          row
        else
          putc '.'
          row[0,9] + row[11, 1] + row[9,2] + row[12..-1]
        end
        new_row[9] = new_row[9].strip.gsub(/ +/, ' ')
        new_row << SecureRandom.uuid if row.size == 14
        destination << new_row
      end
    end

    `mv #{tempfile.path} #{path}`
  end

  task :delete_data do
    system("rm -rf #{server_path.join('data/*')}")
  end

  task load: ['neo4j:stop', :delete_data, 'neo4j:start', :environment] do
    puts 'Loading...'
    cql_erb_path = Rails.root.join('load_csv.cql.erb')
    cql_path = Rails.root.join('load_csv.cql')

    cql_path.write erb(cql_erb_path.read, path: csv_path.to_s)

    command = "#{server_path.join('bin/neo4j-shell')} -file #{cql_path}"
    puts command
    system(command)

  end

  task set_ids: :environment do
    nodes_without_id = Neo4j::Session.query("MATCH (n) WHERE n.id IS NULL RETURN count(n) AS count").first.count
    (nodes_without_id / 14).times do
      putc '-'
      Neo4j::Session.query("MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                            MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}' WITH 1 AS a
                             MATCH (n) WHERE n.id IS NULL WITH n LIMIT 1 SET n.id = '#{SecureRandom.uuid}'")
    end

  end

end
