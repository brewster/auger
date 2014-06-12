#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rainbow/ext/string'


## begin version management
def valid? version
  pattern = /^\d+\.\d+\.\d+(\-(dev|beta|rc\d+))?$/
  raise "Tried to set invalid version: #{version}".color(:red) unless version =~ pattern
end

def correct_version version
  ver, flag = version.split '-'
  v = ver.split '.'
  (0..2).each do |n|
    v[n] = v[n].to_i
  end
  [v.join('.'), flag].compact.join '-'
end

def read_version
  begin 
    File.read 'VERSION'
  rescue
    raise "VERSION file not found or unreadable.".color(:red)
  end
end

def write_version version
  valid? version
  begin
    File.open 'VERSION', 'w' do |file|
      file.write correct_version(version)
    end
  rescue
    raise "VERSION file not found or unwritable.".color(:red)
  end
end

def reset current, which
  version, flag = current.split '-'
  v = version.split '.'
  which.each do |part|
    v[part] = 0
  end
  [v.join('.'), flag].compact.join '-'
end

def increment current, which
  version, flag = current.split '-'
  v = version.split '.'
  v[which] = v[which].to_i + 1
  [v.join('.'), flag].compact.join '-'
end

desc "Prints the current application version"
version = read_version
task :version do
  puts <<HELP
Available commands are:
-----------------------
rake version:write[version]   # set version explicitly
rake version:patch            # increment the patch x.x.x+1
rake version:minor            # increment minor and reset patch x.x+1.0
rake version:major            # increment major and reset others x+1.0.0

HELP
  puts "Current version is: #{version.color(:green)}"
  puts "NOTE: version should always be in the format of x.x.x".color(:red)
end

namespace :version do
  
  desc "Write version explicitly by specifying version number as a parameter"
  task :write, [:version] do |task, args|
    write_version args[:version].strip
    puts "Version explicitly written: #{read_version.color(:green)}"
  end
  
  desc "Increments the patch version"
  task :patch do
    new_version = increment read_version, 2
    write_version new_version
    puts "Application patched: #{new_version.color(:green)}"
  end
  
  desc "Increments the minor version and resets the patch"
  task :minor do
    incremented = increment read_version, 1
    new_version = reset incremented, [2]
    write_version new_version
    puts "New version released: #{new_version.color(:green)}"
  end
  
  desc "Increments the major version and resets both minor and patch"
  task :major do
    incremented = increment read_version, 0
    new_version = reset incremented, [1, 2]
    write_version new_version
    puts "Major application version change: #{new_version.color(:green)}. Congratulations!"
  end
  
end
## end version management

