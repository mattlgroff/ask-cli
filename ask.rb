require 'net/http'
require 'uri'
require 'json'
require 'thread'

def pwd
  `pwd`.strip
end

def ls
  `ls -al`.gsub(/\s+/, ' ').strip
end

def make_openai_request(query, previous_messages = [])
  function_definitions = [
    {
      "name" => "pwd",
      "description" => "Get the current directory",
      "parameters" => {
        "type" => "object",
        "properties" => {}
      },
    },
    {
      "name" => "ls",
      "description" => "Get the contents of the current directory",
      "parameters" => {
        "type" => "object",
        "properties" => {}
      },
    },
  ]

  messages = [
    {
      "role" => "system",
      "content" => "You are a helpful assistant being asked questions from a command line interface."
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
    "model" => "gpt-3.5-turbo-0613",
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
      case last_message['function_call']['name']
      when 'pwd'
        puts "Calling function: pwd"
        function_response = pwd
        previous_messages += [{"role" => "function", "name" => "pwd", "content" => function_response}]
        response = make_openai_request(query, previous_messages)
        process_openai_response(response, query, previous_messages)
      when 'ls'
        puts "Calling function: ls"
        function_response = ls
        previous_messages += [{"role" => "function", "name" => "ls", "content" => function_response}]
        response = make_openai_request(query, previous_messages)
        process_openai_response(response, query, previous_messages)
      else
        raise "Unknown function: #{last_message['function_call']['name']}"
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