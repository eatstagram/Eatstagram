Group Project - Eatstagram README
===
# Eatstagram

## Table of Contents
1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
### Description
Eatstagram is an Instagram version for food.  
It is an iOS app that allows users to build a profile, users can post a picture of foods, they can like pictures and make comments. Users can put the description of that food, and put the location where they take the pictures.

### App Evaluation
- **Category:** Food Photos Social Media
- **Mobile:** Website is for viewing online, mobile first experience. Utilize maps, camera and location features.
- **Story:** People eat foods everyday, they love it so much. This app allow users to appreciate variety of great foods and drinks and share it in pictures. This app will allows family, friends or their connections to either go to the restaurants, or make it themselves at home according to the video or the recipe.
- **Market:** Anyone that loves foods and want to share with families and friends will enjoy this app. Market is focusing towards millienials but not limited to restaurants, home-made chefs, and users within other ages segments too.
- **Habit:** Users can post througout the days for every foods that they eat and drinks. Most users nowadays are already doing this but are not posting it online. Our user interface will designed so that users will post all their photos.
- **Scope:** Instagram is an amazing apps to share pictures, yet there are users that took photos of the foods and not posting it. Because of that, we want to build this App, so users can share what their eat or drink. At the same time, there are lots of others apps that locate restaurants based on your geo-locations but none suggest it based on user's social circle. Our App focusing on this niche needs.

## Product Spec
### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* [x]User can create a new account
* [x]User can login
* [x]User can post a new photo of food
* [x]User can add details and location about the food
* [x]User can view a feed of food photos (sorted by time of post)
* [x]User can like a food photo
* [x]User can add a comment to a photo. After adding, the list of comments is displayed sorted by time of comment.
* [x]User can view location and details of a food photo they select
* [x]User can view all the pictures they uploaded on their profile

**Optional Nice-to-have Stories**

* [ ]User can search for food based on information in Details field
* [ ]User can search based on location of the post
* [ ]User can see which food is available for purchase by the $ sign next to it
* [ ]User's location is auto populated as default but can be edited by the user
* [ ]User can upload their own profile picture
* [ ]User can edit food details of food they had posted
* [ ]User can delete food picture and details posted by the user
* [ ]User can subscribe to food subscription monthly service
* [ ]User can see notifications when their photo is liked
* [ ]User can see a list of those who liked their photos
* [ ]User can view other user’s profiles and see their photo feed
* [ ]User can change Settings of the app
* [ ]User can only post food pictures and their profile picture. Non-food pictures are not allowed when uploading new post. (Use machine learning for this feature)

### 2. Screen Archetypes

* Login Screen
   * User can login
   * When user download/reopening the App, the users is prompted to log in to gain acces to their profile, if they forget their password, the users can put their email and we will send a new password. If they don't have an account, the users can go to the Signup Screen.
* Signup Screen
   * User can create a new account
* Feed Screen (Home)
   * User can view a feed of food photos
   * User can tap a photo to view details
   * User can like a photo
   * User can make a comment
* Detail Screen
   * User can view the detils of the food and the location
* Upload Screen
   * User can post a new food photo along with location and detail
* Profile Screen
   * User can view all the food pictures they have uploaded

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Cancel 
    => Exit the app
* Settings
    => For Future version
* Home
    => Feed Screen
* Search
    => Search Screen (Future version)
* Upload
    => Upload Screen
* Like
    => Adds to the number of likes for the current food photo
* Profile
    => Profile Screen

**Flow Navigation** (Screen to Screen)

*  Login Screen
    => Feed Screen
* Signup Screen
    => Feed Screen
* Feed Screen
    => Settings Screen (Future version)
* Profile Screen
    => Detail Screen
* Upload Screen
    => Feed Screen

## Wireframes
<img src="/images/handdraw.jpeg" width=600>

### [BONUS] Digital Wireframes & Mockups 
<img src="/images/eatstagram.jpeg" width=1000>


### [BONUS] Interactive Prototype
<img src="/images/interactiveI.gif" height="500">

### Progress So Far - Sprint 1
* Users are able to create a new account.
* Users are able to log in based on the account that has been created.

<img src="/images/eatstagram.gif" height="500">

### Progress So Far - Sprint 2
* Database Design. Designed and tested the database dataflow on Firebase and it worked.

<img src="/images/database_design.jpeg" height="500">

* User is able to post a new photo and is able to upload photo to firebase database backend

<img src="/images/eastagram_unit11_update.gif" height="500">

### Progress So Far - Sprint 3
* User can add details and location about the food
* User can view a feed of food photos
* User can like a food photo
* User can add a comment to a photo
* User can view details of a food photo they select
* User can view all the pictures they uploaded on their profile

<img src="/images/sprint3.gif" height="500">

### Progress So Far - Sprint 4
* Tweek previous features to add:  sort post, sort comments, display time of post, display time of comment
* Discussed plan for presentation
* Discussed plan for video
* Fix performance issues such as displaying messages such as loading, etc. while the app is fulfilling user request
* Discuss what optional features can be completed in time left

<img src="/images/sprint4.gif" height="500">



## Schema 

### Data Models
#### Post

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Id            | String   | unique id for each post |
   | user          | Point to User| name and image of user|
   | image         | Url string from Storage     | Image that store in Storage of Google Cloud|
   | numberOflikes       | Integer   | Number of likes of the post |
   | details| String   | Information of the post that user wrote |
   | createdAt     | Timestamp| Date that the post created |
   | comments    | Array | Contains comment (string )and the author of comment |

#### User

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | email            | String   | Email of the user |
   | username          | String| Name of the user|
   | image         | Url string from Storage     | Image that store in Storage of Google Cloud|
   | posts       | point to posts  | All posts that user posted |


### Networking
#### List of network requests by screen
   - Home Feed Screen
      - (Read/GET) Query all posts where user is author
      - (Create/POST) Create a new like on a post
      - (Delete) Delete existing like
      - (Create/POST) Create a new comment on a post
      - (Delete) Delete existing comment
         ```swift
        //Home Feed Screen
        //Fetch the post

        func fetchPost() {
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Firestore.firestore().collection("posts").document(uid).getDocument { (snapshot, err) in
                    if let err = err {
                        print("Faild to fetch swipes info for currently logged in user:", err)
                        return
                    }
                    
                    guard let data = snapshot?.data() else {return}
                    self.posts = data as! [String: Any]
                }
            }

                let query = PFQuery(className:"Post")
                query.whereKey("author", equalTo: currentUser)
                query.order(byDescending: "createdAt")
                query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                    if let error = error { 
                    print(error.localizedDescription)
                    } else if let posts = posts {
                    print("Successfully retrieved \(posts.count) posts.")
                // TODO: Do something with posts...
                    }
                }
         ```      
   - Create Post Screen
      - (Create/POST) Create a new post object
      - (Read/Get) Get current location 
      - (Update/PUT) Post object (image) onto Firestore database
      - (Update/PUT) Post object (location) onto Firestore database
      - (Update/PUT) Post object (Details) onto Firestore database
         ```swift
        //Create Post Screen

        func savePostToFirestore(completion: @escaping (Error?) -> ()) {
                let uid = Auth.auth().currentUser?.uid ?? ""
                let docData: [String : Any] = [
                            "id": id,
                            "user": user,
                            "imageUrl1": imageUrl,
                            "numberOflikes": numberOflikes,
                            "detail": detail,
                            "createdAt": createdAt,
                "comments": comments
                Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                    if let err = err {
                        completion(err)
                        return
                    }
                    completion(nil)
                }
            }

         ```      
   - Profile Screen
      - (Read/GET) Query logged in user object
      - (Update/PUT) Update user profile image
      - (Update/PUT) Update user profile
      - (Delete) Delete existing post
      - (Create/POST) Create a new post
         ```swift
        //Profile Screen 

        //(Read/GET) Query logged in user object

        func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                    if let err = err {
                        completion(nil, err)
                        return
                    }
                    
                    // fetched our user here
                    guard let dictionary = snapshot?.data() else {
                        return
                    }
                    let user = User(dictionary: dictionary)
                    completion(user, nil)
                }
            }

         ```    
