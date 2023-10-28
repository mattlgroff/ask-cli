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

def cat(file, grep_pattern = nil)
  if grep_pattern
    response = `cat #{file} | grep '#{grep_pattern}' 2>&1`.gsub(/\s+/, ' ').strip
  else
    response = `cat #{file} 2>&1`.gsub(/\s+/, ' ').strip
  end
  
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
      "description" => "Concatenate a single file to standard output. Optionally, filter lines with a grep pattern.",
      "parameters" => {
        "type" => "object",
        "properties" => {
          "file": {
            "type": "string",
            "description": "File to concatenate."
          },
          "grep_pattern": {
            "type": "string",
            "description": "Optional grep pattern to filter lines. Example use might be to just grab function definitions in a file.",
            "optional": true
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
    }
  ]
end