//
//  HardCodedUserServices.swift
//  Granite (Better Yelp)
//
//  Created by Matthew on 7/25/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuthUI
import Firebase
import FirebaseDatabase
import FirebaseAuth

// Before we stat our code whenever we are dealing with backend servers what we essentially want is a service layer to keep the stuff that is happening in the background from getting in our way and potentially confusing us

struct UserService {
    static func create(user: HardCodedUsers) {
        
        create(user.username, user.email, user.fullName, user.password)
        
    }
    
    private static func create(_ username: String, _ email: String, _ fullName: String, _ password: String) {
        let user = HardCodedUsers(username: username, email: email , fullName: fullName, password: password)
        let dict = user.dictValue
        let ref = Database.database().reference().child("UsernamesOfUsers").childByAutoId()
        // What this oneline of code above this essentially does is that it lets us give the user in the database a unique identification
        
        ref.setValue(dict)
        
        //So lets go over these lines of code and what they essentially do, so basically we are declaring a private static func and first and foremost we could have done this many ways but we decided to go wit the most security because this would hold our usernames and their credentials in our firebase database, so essentially what we are doing here is that we want this static function which means it cant be overwritten and we call this function create and the parameters this function create contains the null argument label called username and this is of type string then in the next line of code is that we declare a let constant called dict and it holds the dictionary that holds the values for the key usernames and the reason why we did this is something we will address shortly 
        
        // in the next line of code what we essentially do is that we have this let constant called ref and what this essentially does is that it holds the pathway or the reference we made to the place in our firebase database that holds the data for the users usernames and as we know since now we have access to the usernames of the users lets say we have a million user we are not going to scroll all day trying to find an indivdual user so by making another child of the child usernames of users we have this property called child by auto id and what this essentially does is that it lets us give each user with a username a specific user identification which differs from there username 
        
        // Now in the last line of code what we are essentially doing is that we are taking the let constant we declared earlier, ref, and using the set value property which what that does is that it basically writes  to the database fire base location but it doesnt know what to write so remember how we would address why we would create a let constant that basically holds all the dictionary data well this is where we use it so we pass in that data so it know what to write in the firebase location, but you are still probably wondering even though it knows what to write how does it know where to write so the reason we put ref behind this set vle is becuase the let constant holds the pathway to the usernames of users database so thats how it knows where to  write it becuase we are literlaly taking it along the pathway of where we want it to write to 
    }
    
    
    
    // The reason we are not making this private in the first place is becuause we are going to call it later so in a sense we want it public
    static func show(forUID uid: String, completion: @escaping(HardCodedUsers?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = HardCodedUsers(snapshot: snapshot) else{
                // The reason it is giving us this error up above is because we never initialized the data snapshot therefore it is going off of our original initalizer 
                return completion(nil)
                
            }
            completion(user)
        })
    }
    
}
