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

    
    /**
        Fetches all users that the provided user is friends with.

        :param: user The user whose followees you want to retrieve
        :param: completionBlock The completion block that is called when the query completes
    */

    static func getFriendshipAsUserA(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserA, equalTo:user)
        query.whereKey(ParseFriendshipEstablishFriendship, equalTo: true)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        

    }
    
    static func getFriendshipAsUserB(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserB, equalTo: user)
        query.whereKey(ParseFriendshipEstablishFriendship, equalTo: true)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /*
    // Not sure this works
    static func getFriendshipForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        
        // Gets all friendship objects where the user is UserA
        let queryUserA = PFQuery(className: ParseFriendshipClass)
        queryUserA.whereKey(ParseFriendshipUserA, equalTo:user) 
        queryUserA.whereKey(ParseFriendshipEstablishFriendship, equalTo: true)

        // Gets all friendship objects where the user is UserB
        let queryUserB = PFQuery(className: ParseFriendshipClass)
        queryUserB.whereKey(ParseFriendshipUserB, equalTo:user)
        queryUserB.whereKey(ParseFriendshipEstablishFriendship, equalTo: true)
        

       let test =  queryUserA.findObjects()
        for one in test! {
            println((one as! PFObject) )
        }
        let new = 3

        let queryAllFriendUsers = PFUser.query()
        queryAllFriendUsers!.whereKey("username", matchesKey: "UserNameA" /*ParseFriendshipUserA*/, inQuery: queryUserB)
        queryAllFriendUsers!.whereKey("username", matchesKey: "UserNameB"/*ParseFriendshipUserB*/, inQuery: queryUserA)
        queryAllFriendUsers?.findObjectsInBackgroundWithBlock(completionBlock)
    } */
    
    /** 
        Establishes a friend relationship between two users
    
        :param: user The user that is friending another
        :param: toUser The user that is being friended
    */
    
    
    
    ////// OLD
    static func addFriendRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let friendObject = PFObject(className: "Friends")
        friendObject.setObject(user, forKey: "fromUser")
        friendObject.setObject(toUser, forKey: "toUser")
        
        friendObject.saveInBackgroundWithBlock(nil)
    }

    
    
    static func initiateFriendRequest(userA: PFUser, userB: PFUser) {
        let friendshipObject = PFObject(className: ParseFriendshipClass)
        friendshipObject.setObject(userA, forKey: ParseFriendshipUserA)
        friendshipObject.setObject(userB, forKey: ParseFriendshipUserB)
        friendshipObject.setObject(false, forKey: ParseFriendshipEstablishFriendship)
        
        friendshipObject.saveInBackgroundWithBlock(nil)
    }

    
    static func getPendingFriendRequests(userA: PFUser, completionBlock: PFArrayResultBlock) {
        
        // Keep track of who is put in as userA. Current user will always be UserB to confirm UserA's request
        let query = PFQuery(className: ParseFriendshipClass)
        query.whereKey(ParseFriendshipUserA, equalTo: userA)
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
            }
        }
    }
    
    
    // Keep track of who is put in as userA. Current user will always be UserB to reject UserA's request
    static func rejectFriendRequest(userA: PFUser, userB: PFUser) {
        let query = PFQuery(className: ParseFriendshipClass)
        
        query.whereKey(ParseFriendshipUserA, equalTo: userA)
        query.whereKey(ParseFriendshipUserB, equalTo: userB)
        
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
    
    
    
    //////// OLD
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

extension PFObject : Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}
