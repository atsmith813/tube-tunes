require 'dotenv/load'
require 'gmail'
require 'watir'
require 'colorize'

### Loop through Gmail to build the links array with videos to be converted

# YouTube link(s) to be converted
links = []
# Loop through each unread email to get links that will be converted, then mark as read
gmail = Gmail.connect(ENV['EMAIL'], ENV['PASSWORD'])
	gmail.inbox.find(:unread, :subject => ENV['SUBJECT']).each do |email|
		links += email.text_part ? email.text_part.body.decoded.split(' ') : nil
		email.read!
 	end
gmail.logout
puts "No new links were found".red if links.empty?

### Begin converting each link found in Gmail
unless links.empty?
  puts "Starting chrome..."
  # Location that you want to save the files
  download_directory = ENV['DOWNLOAD_DIRECTORY']
  download_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?

  # mp3 converter
  converter = ENV['CONVERTER']

  # Set up Chrome preferences to set download directory and allow automatic downloads
  preferences = {
    download: {
      prompt_for_download: false,
      directory_upgrade: true,
      default_directory: "download_directory"
    }
  }

  # Start browser
  browser = Watir::Browser.new :chrome, prefs: preferences
  browser.window.resize_to 1024, 768

  # Loop through each link that was found from email
  count = 0
  links.each do |link|
    count += 1
  	file_name = nil
  	downloads_before = Dir.entries download_directory

  	# Go to mp3 conversion site
  	browser.goto(converter)
  	# Fill in YouTube video link
  	browser.input(name: 'url').send_keys(link)
  	# Submit form
    puts "Converting..."
  	browser.form(:id, 'convertForm').submit
  	# Waits until video is converted
  	Watir::Wait.until { browser.button(class: ['btn', 'btn-success']).visible? }
  	# Clicks next
  	browser.button(class: ['btn', 'btn-success']).click
  	# Waits until video is ready for download
  	Watir::Wait.until { browser.link(class: ['btn', 'btn-success', 'btn-large']).visible? }
  	# Download
  	browser.link(class: ['btn', 'btn-success', 'btn-large']).click
    puts "Downloading(" + "#{count.to_s}/#{links.size.to_s}".light_cyan +
      ")..."

  	# Checking for our new download
  	difference = Dir.entries(download_directory) - downloads_before
  	# Setting file name of our download
  	file_name = difference.first
  	# Check that file ends in .mp3 to determine if download is complete
  	while !file_name.end_with? ".mp3"
  		sleep 1
  		difference = Dir.entries(download_directory) - downloads_before
  		file_name = difference.first
  	end

  	puts "#{file_name.to_s.light_magenta} was successfully downloaded to #{download_directory.to_s.light_blue}."
  end

  browser.close
end
