#!/usr/bin/env ruby

=begin

  Group 12
  203267 Bastien Antoine
  183785 Denoreaz Thomas
  185078 Dieulivol David

  This script will import data from CSV files given in folder "dataset" to our database.

  ################### Known problems ###################

  1 - Some participants have a weird name. This is due to the encoding Done! above. Hopefully it is seldom the case.

  2 - In the DDL file, we have to delete discipline_id as a primary key because during Import #6 it caused a problem while we added the participants (they all have a       NULL discipline_id).

  3 - In the end, all the athletes that will not have any medals will not have a discipline_id, since this information is not given in the dataset. On all the athletes, only 682 of them will have a medal (that's the data I have with the current dataset at least) :
      "SELECT * FROM Representant_participates_Event RE WHERE discipline_id IS NOT NULL"

  ############### End of Known problems ################

  ####################### Notes ########################

  2 - If you have a problem with the original CSV files, do this command to convert them :
        iconv -t UTF8 -f LATIN1 < athletes_old.csv > athletes.csv

  3 - The default params for the database connection are as follows :
        # db = Mysql.new('host', 'username', 'password', 'your_table')

  ################### End of Notes #####################

=end

def usage
  puts "Usage: ./import_script.rb start [debug]"
  exit
end

case ARGV.size
  when 1 then usage if ARGV[0].downcase != "start"
  when 2 then @debug = ARGV[1].downcase == "debug" ? true : usage
  else usage
end

require 'mysql'
require 'CSV'

db = Mysql.new('localhost', 'root', '', 'db_project_group_12')

# Import #1 : Athletes
puts "Import #1 : Athletes"
i = 0
CSV.foreach("dataset/athletes.csv") do |row|
  db.query("INSERT INTO Athletes (name) VALUES ('#{row.first.gsub("'", "\\\\'")}')") if i > 0
  i += 1
end
puts "Done!"

# Import #2 : Countries
puts "Import #2 : Countries"
i = 0
CSV.foreach("dataset/countries.csv") do |row|
  db.query("INSERT INTO Countries (name, ioc_code) VALUES ('#{row[0]}', '#{row[1]}')") if i > 0
  i += 1
end
puts "Done!"

# Import #3 : Sports
puts "Import #3 : Sports"
i = 0
CSV.foreach("dataset/sports.csv") do |row|
  db.query("INSERT INTO Sports (name) VALUES ('#{row[0]}')") if i > 0
  i += 1
end
puts "Done!"

# Import #4 : Disciplines
puts "Import #4 : Disciplines"
i = 0
CSV.foreach("dataset/disciplines.csv") do |row|  
  if i > 0
    result = db.query("SELECT id from Sports S WHERE S.name='#{row[1]}'")
    result.each_hash {|h| db.query("INSERT INTO Disciplines (name, sport_id) VALUES ('#{row[0].gsub("'", "\\\\'")}', '#{h['id']}')")}
  end
  i += 1
end
puts "Done!"

# Import #5 : Games
puts "Import #5 : Games"
i = 0
CSV.foreach("dataset/games.csv") do |row| 
  
  if i > 0
    year, winter_or_summer = row[0].split(" ")
    is_summer = winter_or_summer.downcase == "summer" ? 1 : 0 unless winter_or_summer.nil?
    host_city, host_country = row[4], row[5]
  
    result = db.query("SELECT id from Countries C WHERE C.name='#{host_country}'")
    result.each_hash do |h|
      db.query("INSERT INTO Games (year, is_summer, host_country, host_city) VALUES ('#{year}', '#{is_summer}', '#{h['id']}', '#{host_city.gsub("'", "\\\\'")}')")
    end
  end
  i += 1
end
puts "Done!"

# Import #6 : Events
puts "Import #6 : Events (long one...)"
i = 0
CSV.foreach("dataset/events.csv") do |row|
  
  discipline = nil
  unless row[1].nil? or row[2].nil?
    result = db.query("SELECT id from Disciplines D WHERE D.name='#{row[1].gsub("'", "\\\\'")}'")
    result.each_hash do |h|
      discipline = h['id'] if i > 0
    end
    
    year, is_summer = row[2].split(" ")
    is_summer = is_summer.downcase == "summer" ? 1 : 0 unless is_summer.nil?
    result = db.query("SELECT id from Games G WHERE G.year='#{year}' AND G.is_summer = '#{is_summer}' ")
    result.each_hash do |h|
      begin
        db.query("INSERT INTO Disciplines_event_Games (discipline_id, games_id) VALUES ('#{discipline}', '#{h['id']}')") if i > 0 and !discipline.nil?
      rescue => ex
        puts "DEBUG (events) : #{ex.message}" if @debug
      end
    end
  end
  i += 1
end
puts "Done!"

# Import #7 : Participants
i = 0
CSV.foreach("dataset/participants.csv") do |row|
  if i > 0 and !row[0].nil? and !row[1].nil? and !row[2].nil?
    athlete_id = nil
    result = db.query("SELECT id from Athletes A WHERE A.name='#{row[0].gsub("'", "\\\\'")}'")
    result.each_hash do |h|
      athlete_id = h['id']
    end
  
    year, is_summer = row[2].split(" ")
    is_summer = is_summer.downcase == "summer" ? 1 : 0 unless is_summer.nil?

    games_id = nil
    result = db.query("SELECT id from Games G WHERE G.year='#{year}' AND G.is_summer = '#{is_summer}' ")
    result.each_hash do |h|
      games_id = h['id']
    end
  
    result = db.query("SELECT id from Countries C WHERE C.name='#{row[1]}'")
    result.each_hash do |h|

      begin
        # Inserts into the Representant aggregate.
        db.query("INSERT INTO Athletes_represent_Countries (athlete_id, country_id) VALUES ('#{athlete_id}', '#{h['id']}')")
        
        # Inserts into the participants table.
        db.query("INSERT INTO Representant_participates_Event (athlete_id, country_id, games_id, ranking) VALUES ('#{athlete_id}', '#{h['id']}', '#{games_id}', 0)")
      rescue => ex
        puts "DEBUG : (participants) : #{ex.message}" if @debug
      end
    end
  end
  i += 1
end
puts "Done!"

# Import #7 : Participants that won a medal (update of participants)
puts "Import #7 : Participants that won a medal (update of participants) ==> Long one!"
i = 0
CSV.foreach("dataset/medals.csv") do |row|
  
  if !row[0].nil? and !row[1].nil? and !row[2].nil? and !row[3].nil? and !row[4].nil? 
    
    # Get the year and split event this way :
    #   Split at "at the <year> <is_summer> - <Discipline>"
    
    country, year, is_summer, discipline = row[0], row[1][/\d+/], row[1].downcase[("summer")], row[1].split("-", 2)[1]
    is_summer = is_summer.nil? ? 0 : 1
    
    # Get the ranking for this line.
    ranking = case row[2].downcase[/^[\S]{4,6}/]
      when "gold" then 1
      when "silver" then 2
      when "bronze" then 3
    end
    
    # Quit if the discipline is not specified
    unless discipline.nil?
      
      # Fetch discipline_id
      discipline_id = nil
      result = db.query("SELECT id from Disciplines D WHERE D.name='#{discipline.gsub("'", "\\\\'").strip}'")
      result.each_hash do |h|
        discipline_id = h['id']
      end
      
      # Fetch country_id
      country_id = nil
      result = db.query("SELECT id from Countries C WHERE C.name='#{country}'")
      result.each_hash do |h|
        country_id = h['id']
      end
      
      # Updates each athlete
      row[3].split(";").each do |athlete|
        begin
          
          # Fetch the athlete_id
          athlete_id = nil
          result = db.query("SELECT id from Athletes A WHERE A.name='#{athlete.gsub("'", "\\\\'")}'")
          result.each_hash do |h|
            athlete_id = h['id']
          end
          
          # Updates the row concerned with the athlete
          my_query = "UPDATE Representant_participates_Event RE SET RE.discipline_id='#{discipline_id}', RE.ranking='#{ranking}' WHERE RE.athlete_id='#{athlete_id}' AND RE.country_id='#{country_id}'"
          db.query(my_query)
          
        rescue => ex
          puts "DEBUG : #{ex.message}" if @debug
        end
      end      
    end
    
  end
  
  i += 1
end
puts "Done!"

db.close