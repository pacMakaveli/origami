#!/usr/bin/env ruby

require 'fileutils'
require 'minitest/autorun'

class FolderOrigamiTest < Minitest::Test
  def setup
    # Create a temporary test structure file
    @test_file = 'test.txt'
    @test_root_dir = 'test'
    
    # Create test structure
    File.open(@test_file, 'w') do |file|
      file.puts @test_root_dir
      file.puts "  ├── Gemfile"
      file.puts "  ├── lib/"
      file.puts "  │   ├── linear_client.rb"
      file.puts "  │   ├── linear/"
      file.puts "  │   │   ├── client.rb"
      file.puts "  │   │   ├── query.rb"
      file.puts "  │   │   ├── label_analyzer.rb  # New file for integration"
      file.puts "  │   │   └── models/"
      file.puts "  │   │       ├── issue.rb"
      file.puts "  │   │       ├── team.rb"
      file.puts "  │   │       └── label.rb       # New model for labels"
      file.puts "  ├── spec/"
      file.puts "  │   └── linear_client_spec.rb"
      file.puts "  └── README.md"
    end
    
    # Expected structure as a nested hash
    @expected_structure = {
      'Gemfile' => true,
      'lib' => {
        'linear_client.rb' => true,
        'linear' => {
          'client.rb' => true,
          'query.rb' => true,
          'label_analyzer.rb' => true,
          'models' => {
            'issue.rb' => true,
            'team.rb' => true,
            'label.rb' => true
          }
        }
      },
      'spec' => {
        'linear_client_spec.rb' => true
      },
      'README.md' => true
    }
  end
  
  def teardown
    # Clean up test files and directories
    # FileUtils.rm_f(@test_file)
    # FileUtils.rm_rf(@test_root_dir) if Dir.exist?(@test_root_dir)
  end
  
  def test_folder_creation
    # Run the origami script
    system("ruby origami.rb #{@test_file}")
    
    # Verify the structure was created correctly
    assert Dir.exist?(@test_root_dir), "Root directory was not created"
    
    # Check the created structure against expected structure
    verify_structure(@test_root_dir, @expected_structure)
  end
  
  def verify_structure(base_path, expected)
    expected.each do |name, content|
      path = File.join(base_path, name)
      
      if content == true
        # It's a file
        assert File.file?(path), "Expected file not found: #{path}"
      else
        # It's a directory
        assert Dir.exist?(path), "Expected directory not found: #{path}"
        
        # Recursively check the contents
        verify_structure(path, content)
      end
    end
  end
  
  # Test for a structure with |---- format
  def test_alternate_format
    # Create a test file with the alternate format
    alt_format_file = 'alt_format_test.txt'
    File.open(alt_format_file, 'w') do |file|
      file.puts @test_root_dir
      file.puts "  |---- Gemfile"
      file.puts "  |---- lib"
      file.puts "  |     |---- linear_client.rb"
      file.puts "  |     |---- linear"
      file.puts "  |          |---- client.rb"
      file.puts "  |          |---- models"
      file.puts "  |                |---- issue.rb"
      file.puts "  |---- README.md"
    end
    
    # Run the script
    system("ruby origami.rb #{alt_format_file}")
    
    # Define expected structure for this format
    alt_expected = {
      'Gemfile' => true,
      'lib' => {
        'linear_client.rb' => true,
        'linear' => {
          'client.rb' => true,
          'models' => {
            'issue.rb' => true
          }
        }
      },
      'README.md' => true
    }
    
    # Verify
    verify_structure(@test_root_dir, alt_expected)
    
    # Clean up
    # FileUtils.rm_f(alt_format_file)
  end
end