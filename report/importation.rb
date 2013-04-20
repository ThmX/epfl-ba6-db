require 'mysql'
require 'CSV'

# Notes : 

# 1 - If you have a problem with the original CSV files, do this command : 
#       iconv -t UTF8 -f LATIN1 < athlete.csv > athlete_new.csv
# 
# 2 - The params for the database connection are below.
db = Mysql.new('localhost', 'root', '', 'projet')

i = 0
CSV.foreach("dataset/athlete_new.csv") do |row|
  db.query("INSERT INTO Athletes (name) VALUES ('#{row.first.gsub("'", "\\\\'")}')") if i > 0
  i += 1
end

i = 0
CSV.foreach("dataset/countries_new.csv") do |row|
  db.query("INSERT INTO Countries (name, ioc_code) VALUES ('#{row[0]}', '#{row[1]}')") if i > 0
  i += 1
end

i = 0
CSV.foreach("dataset/sports_new.csv") do |row|
  db.query("INSERT INTO Sports (name) VALUES ('#{row[0]}')") if i > 0
  i += 1
end

i = 0
CSV.foreach("dataset/disciplines_new.csv") do |row|  
  result = db.query("SELECT id from Sports S WHERE S.name='#{row[1]}'")
  result.each_hash do |h|
    db.query("INSERT INTO Disciplines (name, sport_id) VALUES ('#{row[0].gsub("'", "\\\\'")}', '#{h['id']}')") if i > 0
  end
  i += 1
end

i = 0
CSV.foreach("dataset/games_new.csv") do |row| 
  
  year, winter_or_summer = row[0].split(" ")
  is_summer = winter_or_summer.downcase == "summer" ? 1 : 0 unless winter_or_summer.nil?
  host_city, host_country = row[4], row[5]
  
  result = db.query("SELECT id from Countries C WHERE C.name='#{host_country}'")
  result.each_hash do |h|
    db.query("INSERT INTO Games (year, is_summer, host_country, host_city) VALUES ('#{year}', '#{is_summer}', '#{h['id']}', '#{host_city.gsub("'", "\\\\'")}')") if i > 0
  end
  i += 1
end

i = 0
CSV.foreach("dataset/events_new.csv") do |row|
  
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
      rescue
        puts "Duplicate rows : #{discipline}-----#{h['id']}"
      end
    end
  end
  i += 1
end

i = 0
CSV.foreach("dataset/participants_new.csv") do |row|
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
        puts "ERREUR : #{ex.message}"
      end
    end
  end
  i += 1
end

# 2 - Parse all the medalists and update their entries WITH their Country (in case they are competing for many countries). ==> Next if not already present in the list!

i = 0
CSV.foreach("dataset/medals_new.csv") do |row|
  
  if !row[0].nil? and !row[1].nil? and !row[2].nil? and !row[3].nil? and !row[4].nil? 
    
    # event : Split at "at the <year> <is_summer> - <Discipline>"
    country, year, is_summer, discipline = row[0], row[1][/\d+/], row[1].downcase[("summer")], row[1].split("-")[1]
    is_summer = is_summer.nil? ? 0 : 1
    
    ranking = case row[2].downcase[/^[\S]{4,6}/]
      when "gold" then 1
      when "silver" then 2
      when "bronze" then 3
    end
    
    unless discipline.nil?
      
      discipline_id = nil
      result = db.query("SELECT id from Disciplines D WHERE D.name='#{discipline.gsub("'", "\\\\'")}'")
      result.each_hash do |h|
        discipline_id = h['id']
      end
      
      country_id = nil
      result = db.query("SELECT id from Countries C WHERE C.name='#{country}'")
      result.each_hash do |h|
        country_id = h['id']
      end
      
      # Updates each athlete
      row[3].split(";").each do |athlete|
        begin
          
          athlete_id = nil
          result = db.query("SELECT id from Athletes A WHERE A.name='#{athlete}'")
          result.each_hash do |h|
            athlete_id = h['id']
          end
          db.query("UPDATE Representant_participates_Event RE SET RE.discipline_id='#{discipline_id}', RE.ranking='#{ranking}' WHERE RE.athlete_id='#{athlete_id}' AND RE.country_id='#{country_id}' ")
        rescue => ex
          puts "ERREUR : #{ex.message}"
        end
      end      
    end
    
  end
  
  i += 1
end

db.close