require 'test/unit'

class TestPgaLeaderbord < Test::Unit::TestCase
  def test_getJSON
    t = Leaderboard.new
    
    # Test to show the default pga leaderboard will get a JSON for current tournament
    # Note: The assert will change weekly depending on the tournament in play
    #t = Leaderboard.getJSON('http://www.pgatour.com/leaderboard.html')
    #assert_equal("http://www.pgatour.com/data/r/493/leaderboard-v2.json",t)
    
    # Test to pass in a known tournament id and get back corresponding JSON
    t = Leaderboard.getJSON('033')
    assert_equal("http://www.pgatour.com/data/r/033/leaderboard-v2.json",t)
   
    # Test to pass in a known PGA tournament leaderboard and get back corresponding JSON
    t = Leaderboard.getJSON('http://www.pgatour.com/tournaments/the-rsm-classic/leaderboard.html')
    assert_equal("http://www.pgatour.com/data/r/493/leaderboard-v2.json",t)
   
    # Test to pass in a known World Golf Champions tournament leaderboard and get back corresponding JSON
    t = Leaderboard.getJSON('http://www.worldgolfchampionships.com/hsbc-champions/leaderboard.html')
    assert_equal("http://www.pgatour.com/data/r/489/leaderboard-v2.json",t)
   
    # Test to pass in an incorrect tournament ID and get back a message
    # Tournament ID must be 3 digits long
    t = Leaderboard.getJSON('0334')
    assert_equal("Please enter a correct PGA tournament ID or URL",t)
   
    # Test to pass in an incorrect tournament ID and get back a message
    # Tournament ID must be 3 digits long
    t = Leaderboard.getJSON('33')
    assert_equal("Please enter a correct PGA tournament ID or URL",t)
   
    # Test to pass in an incorrect leaderboard url in the correct format
    t = Leaderboard.getJSON('http://www.pgatour.com/the-us-open/leaderboard.html')
    assert_equal("There is not data available from your requested URL",t)
   
    # Test to pass in an incorrect url
    t = Leaderboard.getJSON('http://www.pgatourinc.com/the-us-open/leaderboard.html')
    assert_equal("Please enter a correct PGA tournament ID or URL",t)
  end
  
  # Test the getData() method which will call the getJSON() method above and then use the returning JSON url to get a hash
  def test_getData
    t = Leaderboard.new
    
    # Test to get default pga leaderboard from a URL
    # Note: The assert will change weekly depending on the tournament in play
    #t = Leaderboard.getData('http://www.pgatour.com/leaderboard.html')
    #assert_equal(69,t.size)
    
    # Test to get default tournament 014 and check the number of elements return matches the numer of players in tournament
    t = Leaderboard.getData('014')
    assert_equal(97,t.size)
    
    # Test to get tournament 033 and check the type of object returned is a hash
    t = Leaderboard.getData('033')
    assert_equal(Hash,t.class)
    
    # Test to pass in a wrong tournament id and ensure I get a string returned.
    # The string will be the error messages
    t = Leaderboard.getData('33')
    assert_equal(String,t.class)
    
  end
  
  def test_saveData
    t = Leaderboard.new
    
    # Test to pass in a tournament reference and a required database name and if successful get a message back 
    #t = Leaderboard.saveData('http://www.pgatour.com/leaderboard.html','test.db')
    #assert_equal("All data saved to DB: test.db successfully.",t)
  end
  
end


require 'json'
require 'open-uri'
#require 'sqlite3'
require 'net/http'

#Adding method to the string class to check if a string is of a numeric value
#http://mentalized.net/journal/2011/04/14/ruby-how-to-check-if-a-string-is-numeric/
class String
  def numeric?
    Float(self) != nil rescue false
  end
end

class Leaderboard

# saveData() saves a returned hash array to a user specified database
def self.saveData(tournament_ref,dbname)
  #open a connection to the users database and create a table if it doesn't already exist.
  db = SQLite3::Database.open "#{dbname}"
  db.execute "CREATE TABLE IF NOT EXISTS pga_leaderboards (id INTEGER, current_position TEXT, current_round INTEGER, country TEXT, is_amateur BOOLEAN, first_name TEXT, last_name TEXT, name TEXT, player_id INTEGER, round1 INTEGER, round2 INTEGER, round3 INTEGER, round4 INTEGER, start_position TEXT, status TEXT, thru INTEGER, today INTEGER, total INTEGER, tournament_name TEXT, tournament_id INTEGER, start_date datetime, end_date datetime, year INTEGER, created_at datetime, updated_at datetime, PRIMARY KEY (player_id, tournament_id, year))"
  
  #User the getData() method to get assign the hash the needs to be stored into a variable
  data_array = getData(tournament_ref)
  
  #loop through the hash and assign the JSON variables to local variables used in the SQL INSERT statement
  for i in 0...data_array.size
    current_position = data_array[i]["current_position"]
    current_round = data_array[i]["current_round"]
    country = data_array[i]["country"]
    #Change boolean value of true/false to 1/0
    if data_array[i]["is_amateur"]
      is_amateur = 1
    else
      is_amateur = 0
    end
    first_name = data_array[i]["first_name"]
    last_name = data_array[i]["last_name"]
    name = data_array[i]["name"]
    player_id = data_array[i]["player_id"]
    round1 = data_array[i]["round1"]
    round2 = data_array[i]["round2"]
    round3 = data_array[i]["round3"]
    round4 = data_array[i]["round4"]
    start_position = data_array[i]["start_position"]
    status = data_array[i]["status"]
    thru = data_array[i]["thru"]
    today = data_array[i]["today"]
    total = data_array[i]["total"]
    tournament_name = data_array[i]["tournament_name"]
    tournament_id = data_array[i]["tournament_id"]
    start_date = data_array[i]["start_date"]
    end_date = data_array[i]["end_date"]
    year = data_array[i]["year"]
    created_at = data_array[i]["created_at"]
    updated_at = data_array[i]["updated_at"]
    
    #Insert the recording into the database and if it exists update the record    
    db.execute('INSERT OR REPLACE INTO pga_leaderboards (current_position, current_round, country, is_amateur, first_name, last_name, name, player_id, round1, round2, round3, round4, start_position, status, thru, today, total, tournament_name, tournament_id, start_date, end_date, year, created_at, updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', current_position, current_round, country, is_amateur, first_name, last_name, name, player_id, round1, round2, round3, round4, start_position, status, thru, today, total, tournament_name, tournament_id, start_date, end_date, year, created_at, updated_at)
  end
  #After the loop is completed pass a message back
  return "All data saved to DB: #{dbname} successfully."
end #end saveData()

#getData() method which takes a tournament reference in and gets the JSON of the data and then returns the data in an array
def self.getData(data)
    #check if data entered is 3 digits long and a number and if it is pass it to the getJSON() for processing
    if data.size == 3  && data.numeric?
      varJSON = getJSON(data)
      return leaderboardArray(varJSON)
    elsif data.start_with?('http://www.pgatour.com/','http://www.worldgolfchampionships.com/') && data.end_with?('/leaderboard.html')
      varJSON = getJSON(data) 
      return leaderboardArray(varJSON)
    else
      #if the data entered does not match the format required then pass back the message below
      return "Please enter a correct PGA tournament ID or URL"
    end
end #end getData()

#getJSON()
def self.getJSON(tournament_ref)
    #if the ref entered is 3 digits long and only numbers then create the JSON url needed
    if tournament_ref.size == 3  && tournament_ref.numeric?
      tournament_url = "http://www.pgatour.com/data/r/#{tournament_ref}/leaderboard-v2.json"
    #if the ref starts with the values below and ends with the value
    elsif tournament_ref.start_with?('http://www.pgatour.com/','http://www.worldgolfchampionships.com/') && tournament_ref.end_with?('/leaderboard.html')
      #Get the source contents of the URL passed in as a ref
      uri = URI(tournament_ref)
      source = Net::HTTP.get(uri)
      base_url = "http://www.pgatour.com"
      #Use a regex to search the page source for /data/r/XXX/leaderboard-v2.json where XXX is any number
      result = source.scan(/\/data\/r\/\d+\/leaderboard-v2.json/)
      #if not JSON link is found on the page the pass a message back
      if result.empty?
        return "There is not data available from your requested URL"
      else
        #if the pattern is found on the page the concatenate it with the base url and pass back the JSON
        tournament_url = base_url+result[0]
        return tournament_url
      end
     else
       return "Please enter a correct PGA tournament ID or URL"
    end  
end #end getJSON

#leaderArray() is a method to create the dataarray for return to the methods above.
def self.leaderboardArray(pgaJSON)
  leaderboard = JSON.load(open(pgaJSON))
  no_of_players = leaderboard['leaderboard']['players'].length
  data_hash = Hash.new
  
  for i in 0...no_of_players
    current_position = leaderboard['leaderboard']['players'][i]['current_position']
    current_round = leaderboard['leaderboard']['players'][i]['current_round']
    country = leaderboard['leaderboard']['players'][i]['player_bio']['country']
    is_amateur = leaderboard['leaderboard']['players'][i]['player_bio']['is_amateur']
    first_name = leaderboard['leaderboard']['players'][i]['player_bio']['first_name']
    last_name = leaderboard['leaderboard']['players'][i]['player_bio']['last_name']
    last_name = last_name.gsub("'","''")  
    name = last_name+", "+first_name
    player_id = leaderboard['leaderboard']['players'][i]['player_id']
    round1 = leaderboard['leaderboard']['players'][i]['rounds'][0]['strokes']
    round2 = leaderboard['leaderboard']['players'][i]['rounds'][1]['strokes']
    round3 = leaderboard['leaderboard']['players'][i]['rounds'][2]['strokes']
    round4 = leaderboard['leaderboard']['players'][i]['rounds'][3]['strokes']
    start_position = leaderboard['leaderboard']['players'][i]['start_position']
    status = leaderboard['leaderboard']['players'][i]['status']
    thru = leaderboard['leaderboard']['players'][i]['thru']
    today = leaderboard['leaderboard']['players'][i]['today']
    total = leaderboard['leaderboard']['players'][i]['total']
    tournament_name = leaderboard['leaderboard']['tournament_name']
    tournament_id = leaderboard['leaderboard']['tournament_id']
    start_date = leaderboard['leaderboard']['start_date']
    end_date = leaderboard['leaderboard']['end_date']
    year = start_date[0...4]
    created_at = Time.now.strftime('%Y-%m-%d %H:%k:%S:%6N')
    updated_at = Time.now.strftime('%Y-%m-%d %H:%k:%S:%6N')
    
    data_hash[i] = { "current_position" => current_position, "current_round" => current_round, "country" => country, "is_amateur" => is_amateur, "first_name" => first_name, "last_name" => last_name, "name" => name, "player_id" => player_id, "round1" => round1, "round2" => round2, "round3" => round3, "round4" => round4, "start_position" => start_position, "status" => status, "thru" => thru, "today" => today, "total" => total, "tournament_name" => tournament_name, "tournament_id" => tournament_id, "start_date" => start_date, "end_date" => end_date, "year" => year, "created_at" => created_at, "updated_at" => updated_at}

    end
    
    return data_hash
end #end leaderboardArray

end #end class
