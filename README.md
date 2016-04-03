# kaleid_o_bot -- kaleidoscope twitter bot

This is the source code of https://twitter.com/kaleid_o_bot a bot that takes images and turns them into kaleidoscope output. The code is written in Processing

There's a bunch of processing kaleidoscope code out there, and I used a lot of ideas found in them. Most of this code generates a mask, applies it to the source to make a triangle-ish shaped chunk of the image, and then writes that chunk out to a new image, rotating it a certain number of times to produce a kaleidoscop-ish image.

* http://www.perlitalabs.com/Kaleidoscope/
* http://www.openprocessing.org/browse/?viewBy=tags&tag=kaleidoscope
* http://davidbu.ch/mann/blog/2011-05-15/picture-kaleidoscope-processing.html
* https://github.com/dbu/kaleidoscope

Learn about the math/physics of kaleidoscopes here:
* http://the-hollander.com/math.html
* http://math2033.uark.edu/wiki/index.php/Kaleidoscopes

I wanted to write a Twitter image bot that would generate kaleidoscopes based on images, and potentially animate them. I spent awhile researching, deriving some code based on the examples above, and the results are @kaleid_o_bot

The code is generic enough that it should be adaptable to other ideas without too much work. It also will post output to tumblr, and has a test mode for running locally, etc.

## Libraries
This code uses a bunch of existing libraries to generate output, including:

* twitter4j - http://twitter4j.org/en/index.html
* gifAnimation -- http://extrapixel.github.io/gif-animation/
* shapetween - http://www.leebyron.com/else/shapetween/
* jumblr - https://github.com/tumblr/jumblr


## Setup
If you want to run the code, you will need to copy 
data/config.properties.example to data/config.properties, and put in credentials for Twitter -- and Tumblr if you want to use that too. If you want to just run some test code, set `use_twitter=false`. When you run the code, it will grab a local file and render it. This is handy for testing, tweaking things, etc.

## Building/Running the App
You can choose to just run the app in the Processing IDE if you want. That certainly works. I'm running @kaleid_o_bot on a remote server so that I can turn my computer off from time to time. Here's the rough steps I use for that:

1) Export the Application. I have a linux server so I export to that.

2) Upload the contents of application.linux64 to your server

3) Install java and Xvfb: `sudo apt-get install xvfb default-jre`

4) Xvfb creates a "virtual frame buffer" which is a fancy term for a virtual monitor that the app will use to generate output. Run Xvfb like so: `Xvfb :1 -screen 0 1152x900x24 -fbdir /tmp &`

5) Run the bot like this `DISPLAY=localhost:1.0 ./kfun`

6) I run all of this in a tmux/screen session, but you could run it as a background process instead. I'll fill out these details later.

## License

WTFPL - http://www.wtfpl.net/
