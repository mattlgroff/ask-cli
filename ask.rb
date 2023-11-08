require 'net/http'
require 'uri'
require 'json'
require 'thread'
require 'base64'
require_relative 'functions'

def capture_screen
  case running_environment
  when 'WSL'
    take_screenshots_wsl
  when 'macOS'
    take_screenshots_macos
  else
    raise "Unsupported environment for taking screenshots."
  end
end

def take_screenshots_wsl
  current_dir_windows_path = `wslpath -m "#{Dir.pwd}"`.strip
  save_path = "#{current_dir_windows_path}\\screenshot"
  script_windows_path = `wslpath -m "#{Dir.pwd}/screen-capture.ps1"`.strip
  system("powershell.exe -ExecutionPolicy Bypass -File \"#{script_windows_path}\" -savePath \"#{save_path}\"")
end

def take_screenshots_macos
  filename = "screenshot_screen_0.png"
  system("screencapture -x \"#{filename}\"")
end

def running_environment
  if File.read('/proc/version').include?('Microsoft') || ENV['WSL_DISTRO_NAME']
    'WSL'
  elsif RUBY_PLATFORM.include?('darwin')
    'macOS'
  elsif RUBY_PLATFORM.include?('linux')
    'Linux'
  else
    'Unknown'
  end
end

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
      "content" => [
        {
          "type" => "text",
          "text" => "You are a helpful assistant being asked questions from a linux command line interface. The current user's username is #{whoami}."
        }
      ]
    }
  ] + conversation_history

  uri = URI.parse("https://api.openai.com/v1/chat/completions")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{ENV['OPEN_AI_API_KEY']}"
  request["Content-Type"] = "application/json"
  request.body = {
    "model" => "gpt-4-vision-preview",
    "messages" => messages,
    "temperature" => 0.2,
    "stream" => false,
  }.to_json

  # Save request body to a file for debugging
  File.open('request_body.json', 'w') do |file|
    file.write(request.body)
  end

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

    # Save response to a file for debugging
    File.open('response.txt', 'w') do |file|
      file.write(response)
    end
  end

  save_conversation_history(conversation_history)
end

conversation_history = load_conversation_history()
function_messages = []

def encode_images_for_api(screenshots_array)
  screenshots_array.map do |screenshot|
    {
      "type" => "image_url",
      "image_url" => {
        "url" => "data:image/png;base64,#{Base64.encode64(File.read(screenshot))}"
      }
    }
  end
end

capture_screen

# Assuming capture_screen method now captures multiple screenshots and returns their paths.
screenshots_array = Dir.glob("screenshot_screen_*.png")

# Encode all screenshots for API upload
encoded_screenshots = encode_images_for_api(screenshots_array)

# Include the user's text message and all the encoded screenshots
user_message_content = [{"type" => "text", "text" => ARGV[0]}] + encoded_screenshots

# Add the user message content array to the conversation history
conversation_history << {
  "role" => "user",
  "content" => user_message_content
}

response = make_openai_request(ARGV[0], conversation_history)
process_openai_response(response, ARGV[0], conversation_history)