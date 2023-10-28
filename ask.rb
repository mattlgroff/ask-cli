require 'net/http'
require 'uri'
require 'json'
require 'thread'
require_relative 'functions'

def load_conversation_history
  if File.exist?('history.json')
    JSON.parse(File.read('history.json'))
  else
    []
  end
end

def save_conversation_history(history)
  File.open('history.json', 'w') do |file|
    file.write(JSON.pretty_generate(history))
  end
end

def make_openai_request(query, conversation_history)
  messages = [
    {
      "role" => "system",
      "content" => "You are a helpful assistant being asked questions from a linux command line interface. The current user's username is #{whoami}."
    }
  ] + conversation_history

  uri = URI.parse("https://api.openai.com/v1/chat/completions")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{ENV['OPEN_AI_API_KEY']}"
  request["Content-Type"] = "application/json"
  request.body = {
    "model" => "gpt-4-0613",
    "messages" => messages,
    "functions" => function_definitions,
    "function_call" => "auto",
    "temperature" => 0.2,
    "stream" => false,
  }.to_json

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  response
end

def process_openai_response(response, query, conversation_history)
  if response.code == '200'
    body = JSON.parse(response.body)
    last_message = body['choices'][0]['message']

    if last_message['function_call']
      function_name = last_message['function_call']['name']
      arguments = JSON.parse(last_message['function_call']['arguments'])

      # Log the function name and arguments
      puts "Calling function: #{function_name}"
      puts "Arguments: #{arguments}"

      case function_name
      when 'ls'
        directory = arguments["directory"] || "."
        begin
          function_response = ls(directory)
        rescue => e
          puts e.message
        end
      when 'pwd'
        function_response = pwd
      when 'whoami'
        function_response = whoami
      when 'grep'
        pattern = arguments["pattern"]
        file = arguments["file"]
        begin
          function_response = grep(pattern, file)
        rescue => e
          puts e.message
        end
      when 'cat'
        file = arguments["file"]
        grep_pattern = arguments["grep_pattern"] || nil
        begin
          function_response = cat(file, grep_pattern)
        rescue => e
          puts e.message
        end
      when 'date'
        function_response = date
      when 'curl'
        url = arguments["url"]
        begin
          function_response = curl(url)
        rescue => e
          puts e.message
        end
      when 'top'
        function_response = top
      when 'ping'
        address = arguments["address"]
        begin
          function_response = ping(address)
        rescue => e
          puts e.message
        end
      else
        raise "Unknown function: #{function_name}"
      end

      conversation_history << {"role" => "function", "name" => function_name, "content" => function_response}
      response = make_openai_request(query, conversation_history)
      process_openai_response(response, query, conversation_history)

    elsif last_message['content']
      content = last_message['content'].strip
      content.gsub!(/```(.*?)```/m) { "\e[32m#{$1.strip}\e[0m" }

      # Add the assistant's response to the conversation history
      conversation_history << {
        "role" => "assistant",
        "content" => content
      }

      puts content
    else
      puts "Error: Unexpected message from assistant: #{last_message}"
    end
  else
    puts "Error: #{response.code}"
    puts "Response body:"
    puts response.body
  end

  save_conversation_history(conversation_history)
end

conversation_history = load_conversation_history()
function_messages = []

# Add the current user message to the conversation history before making the first request
conversation_history << {
  "role" => "user",
  "content" => ARGV[0]
}

response = make_openai_request(ARGV[0], conversation_history)
process_openai_response(response, ARGV[0], conversation_history)