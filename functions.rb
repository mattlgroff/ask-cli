require 'net/http'
require 'json'
require 'uri'
require 'cgi'

def ls(directory=".")
  response = `ls -al #{directory} 2>&1`.gsub(/\s+/, ' ').strip
  if $?.success?
    return response
  else
    raise "Error executing command: ls -al #{directory}. Error message: #{response}"
  end
end

def pwd
  `pwd`.strip
end

def whoami
  `whoami`.strip
end

def grep(pattern, file)
  if File.directory?(file)
    response = `grep -r '#{pattern}' #{file} 2>&1`.gsub(/\s+/, ' ').strip
  else
    response = `grep '#{pattern}' #{file} 2>&1`.gsub(/\s+/, ' ').strip
  end
  
  if $?.success?
    return response
  else
    raise "Error executing command: grep '#{pattern}' #{file}. Error message: #{response}"
  end
end

def cat(file)
  response = `cat #{file} 2>&1`.gsub(/\s+/, ' ').strip
  if $?.success?
    return response
  else
    raise "Error executing command: cat #{file}. Error message: #{response}"
  end
end

def date
  response = `date '+%B %d, %Y @ %I:%M:%S %p'`.strip
  if $?.success?
    return response
  else
    raise "Error executing command: date. Error message: #{response}"
  end
end

def curl(url)
  `curl #{url}`.strip
end

def top
  `top -bn1 | head -n 20`.strip
end

def ping(address)
  `ping -c 4 #{address}`.strip
end

def fetch_hacker_news(type, page, per_page)
  begin
    base_url = "https://hacker-news.firebaseio.com/v0/"
    uri = URI("#{base_url}#{type}stories.json")
    response = Net::HTTP.get(uri)
    ids = JSON.parse(response)
    start_index = (page - 1) * per_page
    end_index = start_index + per_page - 1

    stories = ids[start_index..end_index].map do |id|
      item_uri = URI("#{base_url}item/#{id}.json")
      item_response = Net::HTTP.get(item_uri)
      JSON.parse(item_response)
    end
    # Return the stories as a JSON formatted string
    return JSON.pretty_generate(stories)
  rescue Exception => e
    puts "Error fetching Hacker News stories: #{e.message}"
    return "[]"
  end
end

def do_math_with_wolfram(input)
  base_url = "https://www.wolframalpha.com/api/v1/llm-api"
  app_id = ENV['WOLFRAM_APP_ID']  # Get the AppID from environment variable
  if app_id.nil?
    raise "WOLFRAM_APP_ID is not set in the environment variables"
  end
  
  # URL encode the input and form the final URL
  input_encoded = CGI.escape(input)
  final_url = "#{base_url}?input=#{input_encoded}&appid=#{app_id}&maxchars=5000"
  
  # Make a GET request
  uri = URI(final_url)
  response = Net::HTTP.get(uri)
  
  # You may want to add error handling here depending on your use case
  
  return response
end

def get_current_weather(lat, lon)
  begin
    base_url = "https://api.openweathermap.org/data/2.5/weather"
    app_id = ENV['OPEN_WEATHER_API_KEY']  

    if app_id.nil?
      raise "OPEN_WEATHER_API_KEY is not set in the environment variables"
    end

    final_url = "#{base_url}?lat=#{lat}&lon=#{lon}&units=imperial&appid=#{app_id}"
  
    uri = URI(final_url)
    response = Net::HTTP.get(uri)
  
    return response
  rescue Exception => e
    puts "Error fetching current weather data: #{e.message}"
    return "{}"
  end
end

def get_weather_forecast(lat, lon)
  begin
    base_url = "https://api.openweathermap.org/data/2.5/forecast"
    app_id = ENV['OPEN_WEATHER_API_KEY']  

    if app_id.nil?
      raise "OPEN_WEATHER_API_KEY is not set in the environment variables"
    end

    final_url = "#{base_url}?lat=#{lat}&lon=#{lon}&units=imperial&appid=#{app_id}"
  
    uri = URI(final_url)
    response = Net::HTTP.get(uri)

    puts app_id
    puts response
  
    return response
  rescue Exception => e
    puts "Error fetching weather forecast data: #{e.message}"
    return "{}"
  end
end

def geocode_location_by_city(city, limit=1)
  begin
    base_url = "http://api.openweathermap.org/geo/1.0/direct"
    app_id = ENV['OPEN_WEATHER_API_KEY']  

    if app_id.nil?
      raise "OPEN_WEATHER_API_KEY is not set in the environment variables"
    end

    final_url = "#{base_url}?q=#{CGI.escape(city)}&limit=#{limit}&appid=#{app_id}"
  
    uri = URI(final_url)
    response = Net::HTTP.get(uri)
  
    return response
  rescue Exception => e
    puts "Error geocoding city: #{e.message}"
    return "[]"
  end
end

def geocode_location_by_zip(zip, country_code)
  begin
    base_url = "http://api.openweathermap.org/geo/1.0/zip"
    app_id = ENV['OPEN_WEATHER_API_KEY']  

    if app_id.nil?
      raise "OPEN_WEATHER_API_KEY is not set in the environment variables"
    end

    final_url = "#{base_url}?zip=#{zip},#{country_code}&appid=#{app_id}"
  
    uri = URI(final_url)
    response = Net::HTTP.get(uri)
  
    return response
  rescue Exception => e
    puts "Error geocoding zip code: #{e.message}"
    return "{}"
  end
end



def function_definitions
  [
    {
      "name" => "ls",
      "description" => "Get the contents of a specified directory.",
      "parameters" => {
        "type" => "object",
        "properties" => {
          "directory": {
            "type": "string",
            "description": "The directory to list, e.g. /some/path"
          }
        }
      },
    },
    {
      "name" => "pwd",
      "description" => "Get the current directory",
      "parameters" => {
        "type" => "object",
        "properties" => {}
      },
    },
    {
      "name" => "whoami",
      "description" => "Get the current user. Useful if you need to find a home directory or something specific to the current user.",
      "parameters" => {
        "type" => "object",
        "properties" => {}
      },
    },
    {
      "name" => "grep",
      "description" => "Search for PATTERN in each FILE or standard input. FILE can be a file or a directory. If it's a directory, the command will perform a recursive search.",
      "parameters" => {
        "type" => "object",
        "properties" => {
          "pattern": {
            "type": "string",
            "description": "Pattern to search for."
          },
          "file": {
            "type": "string",
            "description": "File or directory to search."
          }
        }
      },
    },
    {
      "name" => "cat",
      "description" => "Concatenate a single file to standard output.",
      "parameters" => {
        "type" => "object",
        "properties" => {
          "file": {
            "type": "string",
            "description": "File to concatenate."
          }
        }
      },
    },
    {
      "name" => "date",
      "description" => "Get the current date and time.",
      "parameters" => {
        "type" => "object",
        "properties" => {}
      },
    },
    {
      "name": "curl",
      "description": "Download or upload data from/to a specified URL.",
      "parameters": {
        "type": "object",
        "properties": {
          "url": {
            "type": "string",
            "description": "The URL to interact with."
          }
        }
      }
    },
    {
      "name": "top",
      "description": "Display a snapshot of the current processes and their CPU and Memory usage.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    },
    {
      "name": "ping",
      "description": "Check network connection to a specific IP address or domain.",
      "parameters": {
        "type": "object",
        "properties": {
          "address": {
            "type": "string",
            "description": "The IP address or domain to ping."
          }
        }
      }
    },
    {
      "name": "fetch_hacker_news",
      "description": "Fetches stories from Hacker News based on the type, page, and number of stories per page. This function should be used to retrieve data from the Hacker News API in a paginated manner.",
      "parameters": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "description": "The type of stories to fetch. Options are 'top', 'new', 'best', 'ask', 'show', 'job'."
          },
          "page": {
            "type": "integer",
            "description": "The page number of the stories to fetch. Page numbers start from 1."
          },
          "per_page": {
            "type": "integer",
            "description": "The number of stories to fetch per page. For instance, if 'per_page' is set to 20, the function will fetch 20 stories per page."
          }
        }
      },
    },
    {
      "name": "do_math_with_wolfram",
      "description": "Perform mathematical calculations or query data using Wolfram Alpha LLM API.",
      "parameters": {
        "type": "object",
        "properties": {
          "input": {
            "type": "string",
            "description": "The mathematical expression or query for Wolfram Alpha LLM API."
          }
        }
      }
    },
    {
      "name": "get_current_weather",
      "description": "Fetches the current weather data from OpenWeatherMap API.",
      "parameters": {
        "type": "object",
        "properties": {
          "lat": {
            "type": "number",
            "description": "The latitude of the location to fetch current weather data for."
          },
          "lon": {
            "type": "number",
            "description": "The longitude of the location to fetch current weather data for."
          }
        }
      }
    },
    {
      "name": "get_weather_forecast",
      "description": "Fetches the weather forecast from OpenWeatherMap API.",
      "parameters": {
        "type": "object",
        "properties": {
          "lat": {
            "type": "number",
            "description": "The latitude of the location to fetch weather forecast data for."
          },
          "lon": {
            "type": "number",
            "description": "The longitude of the location to fetch weather forecast data for."
          }
        }
      }
    },
    {
      "name": "geocode_location_by_city",
      "description": "Fetches the latitude and longitude of a given city from OpenWeatherMap API.",
      "parameters": {
        "type": "object",
        "properties": {
          "city": {
            "type": "string",
            "description": "The name of the city to fetch coordinates for."
          },
          "limit": {
            "type": "integer",
            "description": "Number of the locations in the API response (up to 5 results can be returned in the API response)."
          }
        }
      }
    },
    {
      "name": "geocode_location_by_zip",
      "description": "Fetches the latitude and longitude of a given zip code from OpenWeatherMap API.",
      "parameters": {
        "type": "object",
        "properties": {
          "zip": {
            "type": "string",
            "description": "The zip code to fetch coordinates for."
          },
          "country_code": {
            "type": "string",
            "description": "The ISO 3166 country code for the zip code."
          }
        }
      }
    }     
  ]
end