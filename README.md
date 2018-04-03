# tube-tunes
Ruby script to convert YouTube videos into MP3 files. I often find remixes on YouTube
that I really enjoy and want to save so I was using a YouTube to MP3 converter that I
found online to convert videos to MP3 files. Then I started getting lazy and not doing
it until I had 15 songs ready to convert at once, which then took some time. So, I wrote
a script in Ruby to automate this process!

## How it works
Whenever I find YouTube videos that I want to convert, I email them to myself with a
designated subject line (i.e. new music) and I paste in the YouTube links sepearted
by spaces ' ' into the body of the email.

The script will poll the inbox for any unread messages of the designated subject line, parse
the body of that message, build an array of YouTube links to be converted, then marks the
message as read.

From here, the script begins to loop through the array and navigate to a popular YouTube to MP3
converter website that I like to use (I'm sure you can find/figure out which one it is)
and begins to programmatically go through the process of converting each video and
downloading the resulting MP3.

## Dependencies/gems
* [dotenv](https://github.com/bkeepers/dotenv "dotenv") - to manage hidden variables (i.e. email address, password, etc.)
* [gmail](https://github.com/gmailgem/gmail "gmail") - to quickly and easily interface with my Gmail account
* [watir](https://github.com/watir/watir "watir") - to navigate the web page of the YouTube to MP3 converter programmatically
* [colorize](https://github.com/fazibear/colorize/ "colorize") - I just really like printing out colors to the console to more easily see the status of the script as it runs
