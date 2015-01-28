/**
 * routines for interacting with twitter
 */
void connectTwitter() {
  println("connecting to twitter");
  twitter.setOAuthConsumer(oauth_consumer_key, oauth_consumer_secret);
  twitter.setOAuthAccessToken(accessToken);

  tweeter.setOAuthConsumer(oauth_consumer_key, oauth_consumer_secret);
  tweeter.setOAuthAccessToken(accessToken);
  println("connected!");
}

// Loading up the access token
private static AccessToken loadAccessToken() {
  return new AccessToken(access_token, access_token_secret);
}

void tweetPic(File _file, String theTweet, Status source) {
  try {
    StatusUpdate status = new StatusUpdate(theTweet);
    status.inReplyToStatusId(source.getId());
    status.setMedia(_file);
    tweeter.updateStatus(status);
  }
  catch (TwitterException te) {
    println("Error: "+ te.getMessage()); 
  }
}

class Listener extends AutoFollowListener {
  public void onStatus(Status status) {
    println(status.getUser().getScreenName() + " - " + username);
    if ( status.getUser().getScreenName().equals(username) ) {
      // println("skipping because it's from me");
      return;
    }

    if ( status.getText().indexOf("@" + username) == -1 ) {
      // println("skipping because it doesn't mention me");
      return;
    }
    
    if ( Arrays.asList(limited_accounts).contains(status.getUser().getScreenName().toLowerCase()) && status.getInReplyToStatusId() > 0 ) {
      println(status.getUser().getScreenName() + " is on the skip list, and this is a reply");
      if ( random(1) <= ignore_chance ) {
        println("ok let's skip it");
        return;
      }
    }
    
    println("@" + status.getUser().getScreenName() + " - " + status.getText());
    String imgUrl = null;
    
    // Checks for images posted using twitter API
    
    MediaEntity[] ents = status.getMediaEntities(); 
    if ( ents.length > 0 ) {
      imgUrl = ents[0].getMediaURL().toString();
    }
    
    if (imgUrl != null) {
      println("found image: " + imgUrl);
      boolean is_jpeg = imgUrl.endsWith(".jpg");      
      imgUrl = imgUrl + ":large";

      // load the large image's raw data, then save as a jpeg and reload
      println("loading " + imgUrl);
      byte[] imgBytes = loadBytes(imgUrl);
      saveBytes("tempImage.jpg", imgBytes);
      imgUrl = "tempImage.jpg";
      
      println("loading " + imgUrl);
      PImage img = loadImage(imgUrl);
      
      renderAndTweet(img, status);
    }
  }
}

