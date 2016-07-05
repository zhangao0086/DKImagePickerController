//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterFacebook.h"
#import "NSString+STUtil.h"

@implementation STExporterFacebook {
}

- (NSString *)SLServiceType; {
    return SLServiceTypeFacebook;
}

+ (NSString *)scheme {
    return @"fb";
}

+ (NSString *)appURLStringWithUserName:(NSString *)userName {
    return [@"fb://profile/" st_add:userName];
}

+ (NSString *)webURLStringWithUserName:(NSString *)userName {
    return [[self webURL] URLByAppendingPathComponent:userName].absoluteString;
}

+ (NSString *)appURLStringWithHashtagName:(NSString *)hashtag {
    return [@"fb://hashtag/" st_add:hashtag];
}

+ (NSString *)webURLStringWithHashtagName:(NSString *)hashtag {
    return [@"http://www.facebook.com/hashtag/" st_add:hashtag];
}

+ (NSString *)webURLString {
    return @"http://facebook.com";
}

@end

/*
 * http://wiki.akosma.com/IPhone_URL_Schemes#Facebook
 *
 * fb://profile – Open Facebook app to the user’s profile
fb://friends – Open Facebook app to the friends list
fb://notifications – Open Facebook app to the notifications list (NOTE: there appears to be a bug with this URL. The Notifications page opens. However, it’s not possible to navigate to anywhere else in the Facebook app)
fb://feed – Open Facebook app to the News Feed
fb://events – Open Facebook app to the Events page
fb://requests – Open Facebook app to the Requests list
fb://notes – Open Facebook app to the Notes page
fb://albums – Open Facebook app to Photo Albums list


 http://stackoverflow.com/questions/5707722/what-are-all-the-custom-url-schemes-supported-by-the-facebook-iphone-app

fb://album?id=%@
fb://background_location
fb://browse?semantic=%@&result_type=%d&source_type=%d&title=%@
fb://codegenerator
fb://composer?%@
fb://composer?pagename=%@&pageid=%@
fb://composer?target=%@
fb://composer?view=location
fb://contactimporter/?ci_flow=%d
fb://discovery
fb://entitycards/?ids=%@&source=%@
fb://event?id=%@
fb://event?id=%@&post_id=%@
fb://eventguestlist?event_id=%@
fb://events/list
fb://eventslist?owner_fbid=%@
fb://f(.+)(\?|&)v=map(\&.*)?
fb://f(.+)incorrect_map_pin(\&.*)?
fb://friendsnearby
fb://friendsnearby/?source=%@
fb://friendsnearby/?source=divebar
fb://friendsnearby/ping?fbid=%@&source=%@
fb://friendsnearby/profile?fbid=%@&source=%@
fb://gift?
fb://group?id=%@
fb://group?id=%@&object_id=%@&view=permalink
fb://hashtag/
fb://hashtag/%@
fb://location_settings
fb://messageComposer?
fb://messaging/new
fb://messaging/new?id=%@&name=%@&isPage=%d
fb://messaging?
fb://messaging?id=%@
fb://messaging?id=%@&%@
fb://messaging?tid=%@
fb://messaginglist
fb://page?id=%@
fb://page?id=%@&source=%@&source_id=%@
fb://page_about?id=%@
fb://page_friend_likes_and_visits?id=%@
fb://page_reviews?id=%@
fb://photo?%@
fb://photo?id=%@
fb://pnp?type=instructions
fb://products?%@
fb://profile
fb://profile/%@
fb://profile?id=%@
fb://profile?id=%@&%@=%@
fb://story?%@
fb://story?graphqlid=%@
fb://story?id=%@
fb://timelineappsection?id=%@
fb://topic/%@
fb://uploadcoverphoto
fb://zrnext
 */