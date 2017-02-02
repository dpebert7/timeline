# Ebert
# updated 11 May 2016

# Goal: Given a Twitter username, find out as much as possible
# about the user

# Setup ----
source("credentials.R") #Load streamR and credentials
1



# Main function ----

get_user_details = function(username, num_tweets = 10, num_followers = 10){
  require(twitteR)
  # Get user's info
  print("Getting user's information...")
  user_info = getUser(username)
  
  # Print off the user's information
  print("Printing user's information...")
  print(user_info$name)
  print(user_info$screenName)
  print(user_info$id)              #<- id is most efficient way of looking up users
  print(user_info$description)     #<- self description may include job/home info
  print(user_info$statusesCount)   #<- number of statuses
  print(user_info$followersCount)  #<- number of followers
  print(user_info$favoritesCount)  #<- tweets favorited?
  print(user_info$friendsCount)    #<- number of friends followed
  print(user_info$url)             #<- possible link to personal website?
  print(user_info$created)
  print(user_info$protected)       #<- not sure exactly what protected means.
  print(user_info$location)        #<- indicator usually of home area
  print(user_info$listedCount)     #<- another indication of popularity
  print(user_info$profileImageUrl) #<- profile image mignt be cool!
  
  # Get user's tweets
  print("Printing user's tweets")
  user_tweets = userTimeline(username, n = num_tweets)
  print(user_tweets)
  
  # Get followers' ID's
  print("Printing followers' ID's")
  follower_ids = user_info$getFollowerIDs(n = num_followers)
  print(follower_ids)
  
  # Get last status
  print("Printing recent status for followers.")
  for(user_id in follower_ids){
    print(user_id)
    recent_tweets = userTimeline(as.numeric(user_id), n = num_tweets)
    print(recent_tweets)
  }
  
}


get_user_details('realDonaldTrump')






# Rate lijmit tests ----

#a = Sys.time()
Sys.time()-a # wait for this to reach 15 secs.
length(trump_info$getFollowerIDs(n = 1000)) # rate limit readched after 15 calls to the function

multiple_users_info = lookupUsers(c('realDonaldTrump','POTUS', 'BadlandsNPS'))
POTUS_tweets = userTimeline('POTUS') # Tweets 



# Old and useless functions ----

# The following functions aren't very useful. They only work on the user's timeline:
homeTimeline()
mentions()
retweetsOfMe()

###################
# streamR package #
###################

# Authenticate streamR
load("my_oauth.Rdata") # Note to avoid reusing credentials, "my_oauth.Rdata" should only be 
# used on the school computer

# Test streamR
# sampleStream(file.name = "junk.json",oauth = my_oauth, timeout = 5)



# Old function used to continuously capture tweets from LA county:
keepCapturingTweets = function(){
  require(streamR)
  require(rjson)
  i = Sys.Date()
  a = Sys.time()
  
  while(1!=0){
    print(Sys.time())
    temp.file.json = paste(Sys.Date(), ".json", sep = "")    
    
    while (Sys.Date()==i){
      filterStream(file.name = temp.file.json, # Save tweets in temporary .json file
                   # Note that this file isn't overwritten after timeout
                   track = c(""), # Collect any tweets from stream; no search term
                   language = "en", # English tweets
                   location = c(-119, 33, -117, 35), # LA county coordinates. 
                   # Note that some tweets just outside the location area may also be collected.
                   timeout = 1800, # Keep connection alive for up to 30 minutes at a time
                   oauth = my_oauth) # Use my_oauth file as the OAuth credentials
      Sys.sleep(1) #pause very briefly before reopening stream
    }
    
    # parse temp.json into R
    print("Posting to Twitter")
    temp.df <- parseTweets(temp.file.json, simplify = FALSE)
    sum = sum + nrow(temp.df)
    tweet_text = paste(nrow(temp.df), " new geotagged tweets collected from LA county. Total: ", 
                       sum,".", sep = "")
    tweet(tweet_text)
    i = Sys.Date() #increment i to new day
  }
}

keepCapturingTweets()