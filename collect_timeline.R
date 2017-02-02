# Ebert
# updated 11 May 2016

# Goal: Given a Twitter username, find out as much as possible
# about the user


source("credentials.R") #Load streamR and credentials


# Look at a user's information
trump_info = getUser('realDonaldTrump')
trump_info$name
trump_info$screenName
trump_info$id              #<- id is most efficient way of looking up users
trump_info$description     #<- self description may include job/home info
trump_info$statusesCount   #<- number of statuses
trump_info$followersCount  #<- number of followers
trump_info$favoritesCount  #<- tweets favorited?
trump_info$friendsCount    #<- number of friends followed
trump_info$url             #<- possible link to personal website?
trump_info$created
trump_info$protected       #<- not sure exactly what protected means.
trump_info$location        #<- indicator usually of home area
trump_info$listedCount     #<- another indication of popularity
trump_info$profileImageUrl #<- profile image mignt be cool!


trump_info$getFollowerIDs(n = 10) # rate limit readched :(


multiple_users_info = lookupUsers(c('realDonaldTrump','POTUS', 'BadlandsNPS'))
POTUS_tweets = userTimeline('POTUS') # Tweets 





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