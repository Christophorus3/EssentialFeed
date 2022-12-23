# EssentialFeed

[![Build Status](https://app.travis-ci.com/Christophorus3/EssentialFeed.svg?branch=master)](https://app.travis-ci.com/Christophorus3/EssentialFeed)

Work from iOS Lead Essentials course.

This is a basic example of how to implement a News Feed or Item Feed with a TDD approach. All Tests are written first, failing. Then the implementation is added, only what is needed to make the tests pass.

This is built using Travis CI.


## Image Feed Feature Specs

### Story: Customer requests to see their image feed

### Narrative #1

```
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed
```

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is less than seven days old
 When the customer requests to see the feed
 Then the app should display the latest feed saved

Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is seven days old or more
 When the customer requests to see the feed
 Then the app should display an error message

Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the feed
 Then the app should display an error message
```

## User Cases

### Load Freed From Remote UseCase

#### Data:
- URL

#### Primary Course (happy path):
1. Execute "Load Image Feed" command with abode data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.

#### Invalid data - error course (sad path):
1. System delivers invalid data error.

#### No connectivity - error course (sad path):
1. System delivers connectivity error.

### Load Feed From Cache Use Case

#### Data:
- Max age (7 days)

#### Primary course
1. Execute "Load Image Feed" command with above data.
2. System fetches feed data from cache.
3. System validates cache is less than 7 days old.
4. System creates image feed from cached data.
5. System delivers image feed.

#### Error course (sad path):
1. System delivers error

#### Expired cache course (sad path):
1. System deletes cache.
2. System delivers no image feed.

#### Empty cache course (sad path):
1. System delivers no image feed.


### Cache Feed Use Case

#### Data:
* Feed items

#### Primary course (happy path):
1. Execute "Save Image Feed" command with above data.
2. System deletes old cache data.
3. System encodes image feed.
4. System timestamps the new cache.
5. System save new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.


