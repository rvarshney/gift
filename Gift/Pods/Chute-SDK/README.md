Setup
====

##Client Authentication

First copy the SDK files into your project.  Find the GCOAuth2Client.m file located at Chute-SDK/Chute-SDK/API and enter your OAuth information.

``` Objective-C
    static NSString * const kGCRedirectURIDefaultValue = @"http://getchute.com/oauth/callback";
    static NSString * const kGCScopeDefaultValue = @"all_resources manage_resources profile resources";

    #define kOAuthTokenURL                  @"http://getchute.com/oauth/access_token"
```

##Login

You need a logged in user to use the SDK.  You can have a single user account for all aspects of the app if you are just displaying images and have limited social interctions or you can have indivdual users log in to their own accounts.

###Single User Account

Having a single user account used by all versions of the app is the easiest to set up.  You can simply save your authentication key to GCClient in 'application:didFinishLaunchingWithOptions:' in your app's delegate file.  You do this by adding the line

``` Objective-C
    [GCClient sharedClient] setAuthorizationHeaderWithToken:@"USER_ACCESS_TOKEN"];
```

###User Login

If you have users login to an account you must first determine which service you want to use.  You set this in GCOAuth2Client files.  There are several popular services to choose from. 
  
``` Objective-C
    static NSString * kGCServices[] = {
    @"chute",
    @"facebook",
    @"twitter",
    @"google",
    @"flickr",
    @"instagram",
    @"foursquare"
};

```

You need to create a view controller for your image picker. You can perform a check if you're already logged in by using GCClient method like this:

``` Objective-C
    if([[GCClient sharedClient] isLoggedIn]==NO)
        [self performSegueWithIdentifier:@"xxx" sender:self.view];
```

In addition it is necessary to create another view controller with couple of buttons which will represent the services available for use to login.
And then when some button is pressed you just simply call GCLoginView method like this:

``` Objective-C
    GCOAuth2Client *oauth2Client = [GCOAuth2Client clientWithClientID:@"xxxxxxxxxxxxxxxxxxxxxxxx"  clientSecret:@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"];
    [GCLoginView showInView:_view fromStartPoint:_startPoint oauth2Client:oauth2Client service:service success:^{
                    [self dismissViewControllerAnimated:YES completion:^{}];
} failure:^{}; 
```

which actually creates a popup view with chosen service interface. You can use failure block to present some UIAlert or something of your choice.

###Logout

If you want your user to be able to log out you simply call

``` Objective-C
    [[GCClient sharedManager] clearAuthorizationHeader];
```

At this point your application will be ready to use the Chute SDK.  Simply `#import "GetChute.h"` in any classes that will be accessing the SDK.

You can also find prebuilt customizable drop in components [here](https://github.com/chute/chute-ios-components).  You can pick and choose which components you want to use and it's a simple way to get working with chute quickly and see the SDK in action.

Key Concepts
========

## Client
All Chute applications use OAuth and are referred to as 'Clients'

## Asset
Any photo or video managed by Chute

##Album
A named collection of assets. Whenever you upload assets, they are grouped into albums.

## Response
Many methods return a response object.  This tells you whether the API call succeeded and includes an error if it didn't.  The response object also has pre-created objects if there were any returned as well as the raw JSON string and the native objective-C decoding of that string.  This allows you to easily get the response in whatever format is most convenient for your project.


Basic Tasks
=========

## Create, Update and Delete an Album

Creating, updating and deleting an album is simple. You just have to call one of these methods:

``` Objective-C
    - (void)createAlbumWithName:(NSString *)name moderateMedia:(BOOL)moderateMedia moderateComments:(BOOL)moderateComments success:(void (^)(GCResponseStatus *responseStatus, GCAlbum *album))success failure:(void (^)(NSError *error))failure

    - (void)updateAlbumWithName:(NSString *)name moderateMedia:(BOOL)moderateMedia moderateComments:(BOOL)moderateComments success:(void (^)(GCResponseStatus *responseStatus, GCAlbum *album))success failure:(void (^)(NSError *))failure

    -(void)deleteAlbumWithSuccess:(void(^)(GCResponseStatus *responseStatus))success failure:(void(^)(NSError *error))failure

```

## Uploading Assets

Uploading assets is now easier than ever. You upload assets using one step uploader.  To perform an upload you first need to create an array of assets you want to upload.  Then you just call the following method from the CGUploader.h

``` Objective-C
	- (void)uploadImages:(NSArray *)images inAlbumWithID:(NSNumber *)albumID progress:(void (^) (CGFloat currentUploadProgress, NSUInteger numberOfCompletedUploads, NSUInteger totalNumberOfUploads))progress success:(void (^) (NSArray *assets))success failure:(void (^)(NSError *error))failure;

```
## Displaying Assets

Assets can be displayed in two ways. You can call GCAlbum method to retrieve all the assets thumbnails from that album like this:

``` Objective-C
    [GCAlbum getAllAssetsWithSuccess:^(GCResponseStatus *responseStatus, NSArray *assets, GCPagination *pagination) {
        <#code#>
    } failure:^(NSError *error) {
        <#code#>
    }];
```

or you can get full detailed version of certain asset like this:

``` Objective-C
    [GCAlbum getAssetWithID:_assetID success:^(GCResponseStatus *responseStatus, GCAsset *asset) {
        <#code#>
    } failure:^(NSError *error) {
        <#code#>
    }]
```

## Import Assets

You can import multiple assets from an array of URL's to an album by calling this method:

``` Objective-C
    - (void)importAssetsFromURLs:(NSArray *)urls success:(void(^)(GCResponseStatus *responseStatus, NSArray *assets, GCPagination *pagination))success failure:(void(^)(NSError *error))failure
```

## Adding and Removing Assets

You can add to or remove from album existing assets by using these methods:

``` Objective-C
    - (void)addAssets:(NSArray *)asssetsArray success:(void(^)(GCResponseStatus *responseStatus))success failure:(void(^)(NSError *error))failure

    - (void)removeAssets:(NSArray *)asssetsArray success:(void(^)(GCResponseStatus *responseStatus))success failure:(void(^)(NSError *error))failure

```
######Note: The assets must already exist either by upload or import. 

##

Social Tasks
==========

## Hearting Assets

You can retrieve heart count for an asset by calling this method:

``` Objective-C
    - (void)getHeartCountForAssetInAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCHeartCount *heartCount))success failure:(void(^)(NSError *error))failure
```

Hearting and unhearting an asset is simple. You just call  the following methods:

``` Objective-C
    - (void)heartAssetInAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus,GCHeart *heart))success failure:(void(^)(NSError *error))failure

    - (void)unheartAssetWithID:(NSNumber *)assetID inAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCHeart *heart))success failure:(void(^)(NSError *error))failure
```

## Commenting on Assets

You can retrieve all comments for an asset by calling this method:

``` Objective-C
    - (void)getCommentsForAssetInAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *responseStatus, NSArray *comments,GCPagination *pagination))success failure:(void (^)(NSError *error))failure
```

There are also two methods for posting a comment and removing comment from an asset

``` Objective-C
    - (void)createComment:(NSString *)comment forAlbumWithID:(NSNumber *)albumID fromUserWithName:(NSString *)name andEmail:(NSString *)email success:(void (^)(GCResponseStatus *responseStatus, GCComment *comment))success failure:(void (^)(NSError *error))failure

    - (void)deleteCommentForAssetWithID:(NSNumber *)assetID inAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCComment *comment))success failure:(void(^)(NSError *error))failure
```

## Tagging Assets

You can retrieve all tags for an asset by using this method:

``` Objective-C
    - (void)getTagsForAssetInAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus,NSArray *tags))success failure:(void (^)(NSError *error))failure
```

There are also methods to add, replace and delete tags from an asset:

``` Objective-C
    - (void)addTags:(NSArray *)tags inAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *responseStatus, NSArray *tags))success failure:(void(^)(NSError *error))failure

    - (void)replaceTags:(NSArray *)tags inAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *responseStatus, NSArray *tags))success failure:(void(^)(NSError *error))failure

    - (void)deleteTags:(NSArray *)tags inAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *responseStatus, NSArray *tags))success failure:(void (^)(NSError *error))failure
```

## Voting Assets

You can retrieve vote count for an asset by calling this method:

``` Objective-C
    - (void)getVoteCountForAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCVoteCount *voteCount))success failure:(void(^)(NSError *error))failure
```

Voting and unvoting an assets is simple. Just call the following methods:

``` Objective-C
    - (void)voteAssetInAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCVote *vote))success failure:(void(^)(NSError *error))failure

    - (void)removeVoteForAssetWithID:(NSNumber *)assetID inAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCVote *vote))success failure:(void(^)(NSError *error))failure
```

## Flag an asset

You can retrieve flag count for an asset by calling this method:

``` Objective-C
    -(void)getFlagCountForAssetInAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCFlagCount *flagCount))success failure:(void(^)(NSError *error))failure
```

You can add or remove flag from an asset by calling one of these methods:

``` Objective-C
    - (void)flagAssetInAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCFlag *flag))success failure:(void(^)(NSError *error))failure

    - (void)removeFlagFromAssetWithID:(NSNumber *)assetID inAlbumWithID:(NSNumber *)albumID success:(void(^)(GCResponseStatus *responseStatus, GCFlag *flag))success failure:(void(^)(NSError *error))failure
```