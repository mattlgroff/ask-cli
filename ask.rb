require 'net/http'
require 'uri'
require 'json'
require 'thread'

def ask_openai(query)
  pwd = `pwd`.strip
  ls = `ls -al`.gsub(/\s+/, ' ').strip
  
  loading_thread = Thread.new do
    i = 0
    loop do
      puts "\rLoading" + "." * ((i % 3) + 1) + " " * (3 - i)
      sleep 0.5
      i = (i + 1) % 3
    end
  end

  uri = URI.parse("https://api.openai.com/v1/chat/completions")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{ENV['OPEN_AI_API_KEY']}"
  request["Content-Type"] = "application/json"
  request.body = {
    "model" => "gpt-3.5-turbo",
    "messages" => [
      {
        "role" => "system",
        "content" => "You are a helpful assistant being asked questions from a command line interface. The current directory is #{pwd} and its contents are: #{ls}"
      },
      {
        "role" => "user",
        "content" => query
      }
    ],
    "temperature" => 0.2
  }.to_json

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  loading_thread.kill
  puts "\r#{' ' * 20}\r" # Clear the loading message

  if response.code == '200'
    body = JSON.parse(response.body)
    content = body['choices'][0]['message']['content'].strip
    # Remove triple backticks and highlight the content inside them
    content.gsub!(/```(.*?)```/m) { "\e[32m#{$1.strip}\e[0m" }
    puts content
  else
    puts "Error: #{response.code}"
  end
end

ask_openai(ARGV[0])
