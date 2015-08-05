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
    
    // User Relation
    static let ParseUserUsername = "username"
    
    // Friendship Relation
    static let ParseFriendshipClass = "Friendship"
    static let ParseFriendshipUserA = "userA"
    static let ParseFriendshipUserB = "userB"
    static let ParseFriendshipEstablishFriendship = "establishFriendship"
    static let ParseFriendshipUsernameA = "usernameA"
    static let ParseFriendshipUsernameB = "usernameB"

    
    /**
        Fetches all users that the provided user is friends with.

        :param: user The user whose followees you want to retrieve
        :param: completionBlock The completion block that is called when the query completes
    */
    
    static func getFriendshipAsUserA(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserA, equalTo:user)
        query.whereKey(ParseFriendshipEstablishFriendship, equalTo: true)
        query.includeKey("userB")
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        

    }
    
    static func getFriendshipAsUserB(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserB, equalTo: user)
        query.whereKey(ParseFriendshipEstablishFriendship, equalTo: true)
        query.includeKey("userA")
    
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        
        /*
        let test =  queryUserA.findObjects()
        for one in test! {
        println((one as! PFObject) )
        }
        let new = 3 */
    }
    
    /** 
        Establishes a friend relationship between two users
    
        :param: user The user that is friending another
        :param: toUser The user that is being friended
    */
    
    static func getFriendRequests(user: PFUser, completionBlock: PFArrayResultBlock) {
        
        // Keep track of who is put in as userA. Current user will always be UserB to confirm UserA's request
        let query = PFQuery(className: ParseFriendshipClass)
        query.whereKey(ParseFriendshipUserB, equalTo: user)
        query.whereKey(ParseFriendshipEstablishFriendship, equalTo: false)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }

    static func initiateFriendRequest(userA: PFUser, userB: PFUser) {
        let friendshipObject = PFObject(className: ParseFriendshipClass)
        friendshipObject.setObject(userA, forKey: ParseFriendshipUserA)
        friendshipObject.setObject(userB, forKey: ParseFriendshipUserB)
        friendshipObject.setObject(false, forKey: ParseFriendshipEstablishFriendship)
        
        friendshipObject.saveInBackgroundWithBlock(nil)
    }
    
    static func getPendingFriendRequests(user: PFUser, completionBlock: PFArrayResultBlock) {
        
        // Keep track of who is put in as userA. Current user will always be userA that sent the pending request.
        let query = PFQuery(className: ParseFriendshipClass)
        query.whereKey(ParseFriendshipUserA, equalTo: user)
        query.whereKey(ParseFriendshipEstablishFriendship, equalTo: false)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    }
    
    // Keep track of who is put in as userA. Current user will always be UserB to confirm UserA's request
    static func confirmFriendRequest(userA: PFUser, userB: PFUser) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserA, equalTo: userA)
        query.whereKey(ParseFriendshipUserB, equalTo: userB)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for friendship in results {
                friendship.setObject(true, forKey: self.ParseFriendshipEstablishFriendship)
                friendship.saveInBackgroundWithBlock(nil)
            }
        }
    }
    
    
    // Keep track of who is put in as userA. Current user will always be UserB to reject UserA's request
    static func rejectFriendRequest(userA: PFUser, userB: PFUser) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserA, equalTo: userA)
        query.whereKey(ParseFriendshipUserB, equalTo: userB)
        /*
        let test =  query.findObjects()
        for one in test! {
            println((one as! PFObject) )
        }
        let new = 3 */
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for friendship in results {
                friendship.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    /** 
        Deletes a friend relationship between two users
            
        :param: user The user that is friending another
        :param: toUser The user that is being friended
    */
    
    static func removeFriendRequest(userA: PFUser, userB: PFUser) {
        let query = PFQuery(className: ParseFriendshipClass)
        query.whereKey("userA", equalTo: userA)
        query.whereKey("userB", equalTo: userB)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for friend in results {
                friend.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    

    static func removeFriendRelationshipFromUser(user1: PFUser, user2: PFUser) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey("userA", equalTo: user1)
        query.whereKey("userB", equalTo: user2)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for friend in results {
                friend.deleteInBackgroundWithBlock(nil)
            }
        }
        
        query.whereKey("userA", equalTo: user2)
        query.whereKey("userB", equalTo: user1)
        
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

extension PFObject : Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}
