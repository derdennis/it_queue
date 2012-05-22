#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'time'
require 'pony'

# Determine directory in which we live
@script_dir = File.expand_path(File.dirname(__FILE__))

# Load config from yaml-file, find it in the @script_dir
CONFIG = YAML.load_file("#{@script_dir}/config.yml") unless defined? CONFIG

# This get's set to 1, if we find a post to publish
build = 0

# This is the deploy command for octopress
deploy_cmd = CONFIG['deploy_cmd']
# This is the dir where octopress lives
build_folder = CONFIG['build_folder']

# Folders where the content lives
drafts_folder = CONFIG['drafts_folder'] 
queue_folder = CONFIG['queue_folder']
posts_folder = CONFIG['posts_folder']
# Maybe check for the upload of referenced images?
images_folder = CONFIG['images_folder']

# Let's go to the drafts_folder!
Dir.chdir(drafts_folder)

puts " "
puts "Now checking for finished drafts..."
puts " "

# Check for drafts in _drafts which were set to "published:true"
Dir['**/*.markdown'].each do |post|
    
    # Tell me at which post you are looking
    print "Checking post ", post, "\n"
    
    # Get the post date from inside the post
    File.open( post ) do |f|
        f.grep( /^date: / ) do |line|
            @post_date = line.gsub(/date: /, "").gsub(/\s.*$/, "")

        end
    end

    # Get the post title from the currently processed post
    @post_title = post.to_s.gsub(/\d{4}-\d{2}-\d{2}/, "")

    # Build the new filename
    @new_post_name = @post_date + @post_title

    File.open( post ) do |f|
        f.grep( /^published: true/ ) do |line|
            # Move these post to the _queue-folder
            print "Moving post ", post, " to queue folder, ", "renaming to ", @new_post_name, "\n"
            FileUtils.mv(post, queue_folder + '/' + @new_post_name)
            puts "=" * 50
        end
    end
end

# Let's go to the queue_folder!
Dir.chdir(queue_folder)
puts " "
puts "Now checking for queued posts, which are ready for publishing..."
puts " "
puts "=" * 50
# Check for the "date: " part of the posts inside of queue. 
Dir['**/*.markdown'].each do |post|
    print "Checking post ", post, "\n"
    File.open( post ) do |f|
        f.grep( /^date: / ) do |line|
            # Show me the filename and the matching line
            #print post, " ", line, "\n"
            # Build a Time-object out of the date string
            post_date = Time.parse(line.gsub(/date: /, "").gsub(/\n$/, ""))
            now_date = Time.now
            print "Post date: ", post_date.inspect, "\n"
            print "Now date: ", now_date.inspect, "\n"

            if post_date < now_date
                puts "Post date is in the past. Publish!"
                #puts "Moving post to posts folder..."
                FileUtils.mv post, posts_folder
                # Set build variable to 1
                build = 1
            else
                puts "Post date is in the future. Do nothing."
            end
            puts "=" * 50 
        end
    end
end

# Do a rake prod_gen_deploy on the mini if the build variable is 1

if build == 1
    puts "We build the site!"
    Dir.chdir(posts_folder)
    system(deploy_cmd)
end

