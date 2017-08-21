require 'dotenv/load'
require 'gmail'
require 'watir'

### Loop through Gmail to buil links array of videos to be converted

# YouTube link(s) to be converted
links = []
# Loop through unread (converted) emails to get links for songs
gmail = Gmail.connect(ENV['EMAIL'], ENV['PASSWORD'])
	gmail.inbox.find(:unread, :subject => ENV['SUBJECT']).each do |email|
		links += email.text_part ? email.text_part.body.decoded.split(' ') : nil   
 	end
gmail.logout

### Begin converting each link found in Gmail

# Location that you want to save the files
download_directory = ENV['DOWNLOAD_DIRECTORY']
download_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?

# mp3 converter
converter = ENV['CONVERTER']

# Set up Chrome preferences to set download directory and allow automatica downloads
preferences = {
  :download => {
    :prompt_for_download => false,
    :directory_upgrade => true,
    :default_directory => "download_directory"
  }   
}  

# Start browser
browser = Watir::Browser.new :chrome, :prefs => preferences

# Loop through each link that was found from email
links.each do |link|
	file_name = nil
	downloads_before = Dir.entries download_directory

	# Go to mp3 conversion site
	browser.goto(converter)
	# Fill in YouTube video link
	browser.input(name: 'url').send_keys(link)
	# Submit form
	browser.form(:id, 'convertForm').submit
	# Waits until video is converted
	Watir::Wait.until { browser.button(:class => ['btn', 'btn-success']).visible? }
	# Clicks next
	browser.button(:class => ['btn', 'btn-success'], :text => 'Continue').click
	# Waits until video is ready for download
	Watir::Wait.until { browser.link(:class => ['btn', 'btn-success', 'btn-large']).visible? }
	# Download
	browser.link(:class => ['btn', 'btn-success', 'btn-large']).click

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

	p "#{file_name} was successfully downloaded to #{download_directory}."
end

browser.close
