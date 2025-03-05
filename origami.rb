#!/usr/bin/env ruby

require 'fileutils'

# Function to parse the directory structure
def parse_directory_structure(input_text)
  lines = input_text.strip.split("\n")
  structure = {}
  
  # Remove the first line (project name)
  project_name = lines.shift.strip.chomp('/')
  structure = { project_name => {} }
  
  current_path = []
  current_level = 0
  
  lines.each do |line|
    next if line.strip.empty?
    
    # Calculate indentation level (number of spaces)
    spaces = line.match(/^\s*/)[0].length
    level = spaces / 2
    
    # Adjust current path based on indentation
    if level > current_level
      # Going deeper
    elsif level < current_level
      # Going up
      (current_level - level).times { current_path.pop }
    else
      # Same level, replace last component
      current_path.pop if !current_path.empty?
    end
    
    current_level = level
    
    # Extract the item (file or directory), ignoring line drawing characters
    item = line.strip
                .gsub(/^[├└]── /, '')
                .gsub(/^[│]?\s*[├└]?── /, '')
                .gsub(/^[│]\s*/, '')
                .gsub(/^\|----/, '')  # Handle |---- format
                .gsub(/^\|/, '')      # Handle | format
    
    # Check if it's a directory or file
    if item.end_with?('/')
      # Directory
      item = item.chomp('/')
      current_path.push(item)
      
      # Update structure
      path = current_path.dup
      node = structure[project_name]
      path.each do |part|
        node[part] ||= {}
        node = node[part]
      end
    else
      # File
      # Remove any comment from the file name
      file_name = item.split('#').first.strip
      
      current_path.push(file_name)
      
      # Update structure - for files, set the value to true
      path = current_path.dup
      node = structure[project_name]
      
      # Navigate to the parent directory
      parent_path = path[0...-1]
      parent_path.each do |part|
        node[part] ||= {}
        node = node[part]
      end
      
      # Add the file
      node[path.last] = true
      
      current_path.pop  # Remove the file from the current path
    end
  end
  
  structure
end

# Function to create directories and files from the structure
def create_from_structure(structure)
  structure.each do |root, content|
    create_recursive(root, content)
  end
end

def create_recursive(path, content)
  if content == true
    # It's a file
    FileUtils.touch(path)
    puts "Created file: #{path}"
  else
    # It's a directory
    FileUtils.mkdir_p(path)
    puts "Created directory: #{path}"
    
    content.each do |name, subcontent|
      create_recursive(File.join(path, name), subcontent)
    end
  end
end

# Main execution
if ARGV.empty?
  puts "Please provide the directory structure as a multiline input, then press Ctrl+D when finished:"
  input_text = STDIN.read
else
  input_text = File.read(ARGV[0])
end

structure = parse_directory_structure(input_text)
create_from_structure(structure)