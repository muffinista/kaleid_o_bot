
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Properties;
 
import java.io.FileNotFoundException;

import twitter4j.*;
import gifAnimation.*;

import com.tumblr.jumblr.types.*;
import com.tumblr.jumblr.exceptions.*;
import com.tumblr.jumblr.responses.*;
import com.tumblr.jumblr.*;
import com.tumblr.jumblr.request.*;

float MASK_SCALE = 1.2f;
float AXIS_PADDING = 0.4;

// scaling will clip the outside edge of the image chunk, which
// means that our output won't look like a wacky circle
float SLICE_SCALE_AMOUNT = 1.2f;

String username;

// This is where you enter your Oauth info
String oauth_consumer_key;
String oauth_consumer_secret;

// This is where you enter your Access Token info
static String access_token;
static String access_token_secret;

String tumblr_consumer_key;
String tumblr_consumer_secret;
String tumblr_oauth_token;
String tumblr_oauth_secret;
String tumblr_blog_dest;


// streaming api handler
TwitterStream twitter;
AccessToken accessToken;

// separate object for sending out tweet replies
Twitter tweeter;

// we'll output different resolutions for animated gifs vs single frames to get around twitter's image size limits
int output_width = 1280;
int output_height = 1080;

int animated_output_width = 600;
int animated_output_height = 600;
int output_frames = 40;

// and we'll mess with tubmlr options too
int tumblr_output_width = 500;
int tumblr_output_height = 500;
int tumblr_output_frames = 15;

// set to true to connect to twitter and work as a bot
// set to false for running test code
boolean use_twitter = true;

// accounts that we might ignore if we're in a canoe
String limited_accounts[] = new String[]{
  "badpng",
  "img2ascii",
  "ushouldframeit",
  "jpgglitchbot",
  "commonsbot",
  "imgshredder",
  "lowpolybot",
  "pixelsorter",
  "smoorpio"};
float ignore_chance = 0.20f;

Listener listener;

void setup() {
  size(1280, 1080);
  noLoop();
  loadConfig();

  if ( use_twitter ) {
    accessToken = loadAccessToken();
    ConfigurationBuilder builder = new ConfigurationBuilder();
    builder.setDebugEnabled(true);
    builder.setOAuthConsumerKey(oauth_consumer_key);
    builder.setOAuthConsumerSecret(oauth_consumer_secret);
    builder.setOAuthAccessToken(access_token);
    builder.setOAuthAccessTokenSecret(access_token_secret);
    Configuration conf = builder.build();
    twitter = new TwitterStreamFactory(conf).getInstance();

    tweeter = new TwitterFactory(conf).getInstance();

    try {
      username = tweeter.getScreenName();
      println("connected to twitter as " + username);
    } 
    catch(Exception ex) { 
      ex.printStackTrace();
    }


    listener = new Listener();
    twitter.addListener(listener);
  }
}

void draw() {
  if ( use_twitter ) {
    // listen for tweets
    twitter.user();
  }
  else {
    background(0);
    // render a test image
    Request r = new Request(this, loadImage("test.png"), "#20frames #west #noanimate");

    PGraphics x = r.renderSingleFrame();
    println(x);
    image(x, 0, 0);
  }
}

void mouseClicked() {
 draw(); 
}

/**
 * generate a Request from the incoming tweet, then do some work and send back the response
 */
void renderAndTweet(PImage img, Status source) {
  Request r = new Request(this, img, source);

  String source_user = source.getUser().getScreenName();

  // small chance of posting to tumblr. this is sort of dumb
  boolean post_to_tumblr = ( random(0, 10) <= 1 );

  if ( r.animate ) {
    File temp = r.renderAnimated(output_frames);
    String text = "@" + source_user + " here you go " + r.slices() + "slices animate";  
    tweetPic(temp, text, source);

    if ( post_to_tumblr == true ) {
      postToTumblr(temp);      
    }
  }
  else {
    PGraphics pg = r.renderSingleFrame();

    try {
      File temp = File.createTempFile("kaleidoscope", ".png"); 
      System.out.println("Temp file : " + temp.getAbsolutePath());
      pg.save(temp.getAbsolutePath()); 
      
      String text = "@" + source_user + " here you go " + r.angleToHash() + " " + r.slices() + "slices";  
      tweetPic(temp, text, source);

      if ( post_to_tumblr == true ) {
        postToTumblr(temp);      
      }
      
      println("saved!");
    } 
    catch(IOException ex) { 
      ex.printStackTrace();
    }
  }
}

/**
 * post an image to tumblr. whee!
 */
void postToTumblr(File f) {
  try {
    println("posting to tumblr!");

    // Create a new client
    JumblrClient client = new JumblrClient(tumblr_consumer_key, tumblr_consumer_secret);
    client.setToken(tumblr_oauth_token, tumblr_oauth_secret);

    println("(post to): "+ tumblr_blog_dest);
    PhotoPost post = client.newPost(tumblr_blog_dest, PhotoPost.class);
    post.setData(f);
    post.save();
  }
  catch(Exception e) {
    println(e);
    e.printStackTrace();
  }
}