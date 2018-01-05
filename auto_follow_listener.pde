/**
 * boring twitter stream adapter that just follows users who follow it. you can extend this to add other interactions
 */
class AutoFollowListener extends UserStreamAdapter {
  public void onStatus(Status status) {
  }

  public void onException(Exception ex) {
    ex.printStackTrace();
  }

  public void onFollow(twitter4j.User source, twitter4j.User followedUser) {
    System.out.println("onFollow source:@" + source.getScreenName() + " target:@" + followedUser.getScreenName());
              
    if ( source.getScreenName().toLowerCase().equals(username) ) {
      return;
    }

    try {
      tweeter.createFriendship(source.getId());
    }
    catch (TwitterException te) {
      println("Error: "+ te.getMessage()); 
    }
  }
}