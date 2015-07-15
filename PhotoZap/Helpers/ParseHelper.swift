//
//  ParseHelper.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/14/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    // Friend Relation
    static let ParseFriendClass = "Friends"
    static let ParseFriendFromUser = "fromUser"
    static let ParseFriendToUser = "toUser"
    
    // User Relation
    static let ParseUserUsername = "username"
    
    /** 
        Fetches all users that the provided user is friends with.

        :param: user The user whose followees you want to retrieve
        :param: completionBlock The completion block that is called when the query completes
    */
    
    static func getFriendUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: "Friends")
        
        query.whereKey("fromUser", equalTo:user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        // Error?
    }
    
    /** 
        Establishes a friend relationship between two users
    
        :param: user The user that is friending another
        :param: toUser The user that is being friended
    */
    
    static func addFriendRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let friendObject = PFObject(className: "Friends")
        friendObject.setObject(user, forKey: "fromUser")
        friendObject.setObject(toUser, forKey: "toUser")
        
        friendObject.saveInBackgroundWithBlock(nil)
    }
    
    
    /** 
        Deletes a friend relationship between two users
            
        :param: user The user that is friending another
        :param: toUser The user that is being friended
    */
    
    static func removeFriendRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: "Friends")
        
        query.whereKey("fromUser", equalTo: user)
        query.whereKey("toUser", equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for friend in results {
                friend.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    // MARK: Users
    
    /** 
        Fetch all users, except the one that's currently signed in
        Limits the amount of users returned to 20
        
        :param: completionBlock The completion block that is called when the query completes
        
        :returns: The generated PFQuery
    */
    
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        
        // exclude the current user
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    /** 
        Fetch users whose usernames match the provided serach term
        
        :param: searchText The text that should be used to search for users
        :param: completionBlcok The completion block that is called when the query completes

        :returns: The generated PFQuery
    */
    
    static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock) -> PFQuery {
        
        /*
        NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
        Regex can be slow on large datasets. For large amount of data it's better to store
        lowercased username in a separate column and perform a regular string compare.
        */

        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername, matchesRegex: searchText, modifiers: "i")
        
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
        
    }
    
}
