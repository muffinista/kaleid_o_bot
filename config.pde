import java.io.ByteArrayInputStream;


void loadConfig() {
  String result = "";
  Properties prop = new Properties();
  String propFileName = "config.properties";
 
  try {
     InputStream inputStream = new ByteArrayInputStream( loadBytes(propFileName) );

    if (inputStream != null) {
      prop.load(inputStream);
    } else {
      throw new FileNotFoundException("property file '" + propFileName + "' not found in the classpath");
    }

    oauth_consumer_key =  prop.getProperty("oauth_consumer_key");
    oauth_consumer_secret = prop.getProperty("oauth_consumer_secret");

    access_token = prop.getProperty("access_token");
    access_token_secret = prop.getProperty("access_token_secret");

    tumblr_consumer_key =  prop.getProperty("tumblr_consumer_key");
    println("(tumblr_consumer_key): "+(tumblr_consumer_key));

    tumblr_consumer_secret =  prop.getProperty("tumblr_consumer_secret");
    println("tumblr_consumer_secret: "+tumblr_consumer_secret);

    tumblr_oauth_token =  prop.getProperty("tumblr_oauth_token");
    println("tumblr_oauth_token: "+tumblr_oauth_token);

    tumblr_oauth_secret =  prop.getProperty("tumblr_oauth_secret");
    println("tumblr_oauth_secret: "+tumblr_oauth_secret);

    tumblr_blog_dest =  prop.getProperty("tumblr_blog_dest");
    println("tumblr_blog_dest: "+tumblr_blog_dest);

    use_twitter =  Boolean.parseBoolean(prop.getProperty("use_twitter"));
    println("use_twitter: "+use_twitter);
  }
  catch(IOException e) {
    println(e);
    e.printStackTrace();
  }
}