require 'net/http'
require 'uri'
require 'json'
require 'thread'
require_relative 'functions'

def make_openai_request(query, previous_messages = [])
  messages = [
    {
      "role" => "system",
      "content" => "You are a helpful assistant being asked questions from a linux command line interface. The current user's username is #{whoami}."
    },
    {
      "role" => "user",
      "content" => query
    }
  ] + previous_messages

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

def process_openai_response(response, query, previous_messages = [])
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
        directory = JSON.parse(last_message['function_call']['arguments'])["directory"] || "."
        begin
          function_response = ls(directory)
          previous_messages += [{"role" => "function", "name" => "ls", "content" => function_response}]
          response = make_openai_request(query, previous_messages)
          process_openai_response(response, query, previous_messages)
        rescue => e
          puts e.message
        end
      when 'pwd'
        function_response = pwd
        previous_messages += [{"role" => "function", "name" => "pwd", "content" => function_response}]
        response = make_openai_request(query, previous_messages)
        process_openai_response(response, query, previous_messages)
      when 'whoami'
        function_response = whoami
        previous_messages += [{"role" => "function", "name" => "whoami", "content" => function_response}]
        response = make_openai_request(query, previous_messages)
        process_openai_response(response, query, previous_messages)
      when 'grep'
        pattern = arguments["pattern"]
        file = arguments["file"]
        begin
          function_response = grep(pattern, file)
          previous_messages += [{"role" => "function", "name" => "grep", "content" => function_response}]
          response = make_openai_request(query, previous_messages)
          process_openai_response(response, query, previous_messages)
        rescue => e
          puts e.message
        end
      when 'cat'
        file = arguments["file"]
        begin
          function_response = cat(file)
          previous_messages += [{"role" => "function", "name" => "cat", "content" => function_response}]
          response = make_openai_request(query, previous_messages)
          process_openai_response(response, query, previous_messages)
        rescue => e
          puts e.message
        end
      when 'date'
        function_response = date
        previous_messages += [{"role" => "function", "name" => "date", "content" => function_response}]
        response = make_openai_request(query, previous_messages)
        process_openai_response(response, query, previous_messages)      
      else
        raise "Unknown function: #{function_name}"
      end
    elsif last_message['content']
      content = last_message['content'].strip
      content.gsub!(/```(.*?)```/m) { "\e[32m#{$1.strip}\e[0m" }
      puts content
    else
      puts "Error: Unexpected message from assistant: #{last_message}"
    end
  else
    puts "Error: #{response.code}"
    puts "Response body:"
    puts response.body
  end
end

response = make_openai_request(ARGV[0])
process_openai_response(response, ARGV[0])