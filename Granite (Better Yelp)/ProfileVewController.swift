//
//  ProfileVewController.swift
//  Granite (Better Yelp)
//
//  Created by Matthew on 7/26/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreData


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var authHandle: AuthStateDidChangeListenerHandle?
    var database: Database!
    var storage: Storage!
    var picArray: [UIImage] = []
    var hardCodedUsers = [HardCodedUsers]()
    @IBOutlet weak var profileImage: UIImageView!
    var username: String?
    //    var users = [HardCodedUsers]()
    @IBOutlet weak var userBio: UITextView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    var hello = 3
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfile()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        authHandle = authListener(viewController: self)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
    view.endEditing(true)
    }
    // So essentially with the code that is about to come what we have to do is instead of saving the profile image to user defaults we can constantly be listening to the profile pic of the user  and listen for any updates and every time the  user opens up the app we can retrieve the photo from firebase
        func presentLogOut(viewController: UIViewController) {
        let logOutAlert = UIAlertController(title: "Log Out", message: "Continue with this action if you want to log out", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"Log Out", style: .default, handler: { _ in
            self.logUserOut()
        })
        logOutAlert.addAction(cancelAction)
        self.present(logOutAlert, animated: true, completion: nil)
        
        // So let us tackle this code line by line and see the previous issue we were having was, so the original issue we were having was that whenever the user pressed the log out button they would just be presented with a log out alert and when they pressed the cancel action nothing would actually happen and the reason for that happening was becauase their was actually no functionality within that cancel action
        
        // The way we went about this was by taking this function we declared called logUserOut and placing it within the handler argument parameter labels
        // As we know what a handler as well as a completion with little to no difference what those essentially do is that they let us do is that they return an action with the specified and title behavior therefore when they press the cancel button on the logout button the code within the log user out will be executed
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        
        presentLogOut(viewController: self)
        // What this is essentially doing is that it is presenting the log out alert which makes sense becauase when the user taps on the log in button we want the alert to show up
    }
    
    func authListener(viewController view: UIViewController) -> AuthStateDidChangeListenerHandle{
        let authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user == nil
                else {return}
            let storyboard = UIStoryboard(name: "LogInStoryBoard", bundle: .main)
            guard let controller = storyboard.instantiateInitialViewController() else {
                fatalError()
            }
            view.view.window?.rootViewController = controller
            view.view.window?.makeKeyAndVisible()
            // So in culmination with the loguserout function what this essentially does is that it lets us return to the log in storyboard when the user logs out but what is actually signing the user out of firebase is the log user out function
        }
        return authHandle
    }
    func removeAuthListener (authHandle: AuthStateDidChangeListenerHandle?)
    {
        if let authHandle = authHandle{
            
            Auth.auth().removeStateDidChangeListener(authHandle)
            
        }
        // So as we know what is happening is that what a handler does is that creates and returns an action with the specified behavior so what this does is almost like a setting function because what we are essentially doing is that we are changing the code within firebase to say change the listener block to a block that essentailly tells us that the user has signed out
    }
    
    func logUserOut() {
        do{
            try Auth.auth().signOut()
        } catch let error as NSError {
            assertionFailure("Error: error signing in \(error.localizedDescription)")
        }
        // So this block of code is detrimental to our code and what it  does exactly that it lets us log the user out so let us tackle this code line by line
        // we essentially want the code to sign our the verified user and we know if the user isnt verified then they cant be signed in
        // If their is an error with signing the user out then the error will be printed out in the console
    }
    
    let storageRef = Storage.storage().reference()
    var databaseRef = Database.database().reference()
    
    @IBAction func saveChanges(_ sender: UIButton) {
        saveChanges()
        saveUserBioChanges()
        
        
        
    }
    
    @IBAction func uploadImageButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated:  true, completion: nil)
        
        // So what we are essentially doing let us take this to the basics first and foremost what is happening is that we are saying that when the user presses upon this uploadImageButton that we want the following code to be executed and what is going to happpen is that we want to give this let constant we are declaring calledpicker to essentially be its own delegate and what that means is that we are giving its own set of protocols or in other words we can think about this in the way that we are giving it its own set of blueprints as opposed to making it subjugated to the default blueprints or protocols it originally came from
        
        // in the next line of code what is essentially happening is that well first we are making this picker of type uiimagepickercontroller and what that it essentially does is that it gives us all the properties of the uiimagepickercontroller within this picker controller and then from there we make it its own delegate and like we said that gives us our own set of blueprints and in the next line of code we are basically saying that we can allow editing meaning if they can modify the existing image
        
        // In the next line of code what is essentially happening is that we are giving a source for these photos to come from and for that source we are using the uiimagepickercontroller photo library meaning we have access to all the default photos
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveUserBioChanges() {
        if !userBio.text.isEmpty,
            let text = userBio.text{
            // Save changes to the users bio
            if let userID = Auth.auth().currentUser?.uid {
                databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    //                    let values = snapshot.value as? NSDictionary
                    //                    self.userBio.text = values?["userBio"] as? String
                    print("The users bio has not been saved locally in user defaults yet but has been changed")
                    self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["userBio" : text])
                    //                    let values = snapshot.value as? NSDictionary
                    //                    text = values?["userBio"] as? String
                    
                    // So essentially what is happening here is that we are basically saying thay when we press the save changes button we want to save the bio text and the reason we commented out the two lines of code here is because lets think about this we are declaring this new let constant called values and setting that equal to the snapshot from firebase and casting it as a dictionary and we know we cast them as a dictionary because we want to have a key and return the users info as a value and in the second line of code what we are essentially doing here is that we are saying that we want the user bio text equal to the dictionary key userBio now the problem with that is we are basically saying that we want the userbio text equal to the dictionary key but when we start the app and tap on the user the text is initially empty therefore it is going to store it as empty, thats why whenever we started the app the user bio was stored as an empty string in firebase so to go about this what we did was commentented the line out and then from there what we have is take this database reference to firebase to our users database and esserntially say we want to update our userBio child with the userbio text and we there declare it as a key value pair as you can see we set the text equal to the key userBio
                    
                    // And the reason we dont want to initalize is it because for this simple reason and that reason being is that every user has to have a username an email and a password ass well as their fullname to create their account but not ever user has to have a bio thereofore as we know every instance of a class represents a new user therefore we dont initalize t because if we did that means that every new user would have to have a bio
                    
                    // The next step is to be able to save their bio therefore when they restart the app their bio is still there and this incorporates user defualts
                })
            }
        }
    }
    
    func saveChanges() {
        // Save changes to the modifications we made to the profile
        
        
        let imageName = NSUUID().uuidString
        
        let storedImage = storageRef.child("profileImage").child(imageName)
        
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!)
        {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                    
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error)
                        return
                        
                    }
                    if let urlText = url?.absoluteString{
                        self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["pic" : urlText], withCompletionBlock: { (error, ref ) in
                            if error != nil {
                                print(error)
                                return
                                
                            }
                        })
                        
                    }
                })
            })
        }
        print("The user's profile image has been saved to their profile")
        
        // Their image is succesfully chnaging but what is occuring is that the username is all under one users name as well as the image doesnt actually change it justs does in firebase but since they are all under one username what is occuring is that the photos are only saving within that users values for pic
        
        // So what we have to do is first fix the issue that when we press the save changes button the username saves for all the users but what we want is that when we press the save change button that it only saves for the individual user
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,  didFinishPickingMediaWithInfo info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
            
        }
        dismiss(animated: true, completion: nil)
        
        // What this function essentially allows us to do is that it is basically saying that if the user edits the image ket that be the image that is set for their profile
        
        // the second condition basically states that if the user chooses to leave the originial images as their profile image let that happen
        
        // if the user chooses the selected image then let that be the image that is set as their profile image
    }
    
    deinit {
        removeAuthListener(authHandle: authHandle)
        // So we can thing of this init as a cleanup before deallocating memory and what this essentially does is that it lets us clean up our code before it is returned to memory and what that essentially means is that it lets us change the listener block basically deinitializing the user after they log out so in essence when they log our they are getting initalized again and i know that may be confusing so if we further elaborate what is essentially happening is that we aee
    }
    func saveImageUserDefaults () {
        
    }
    //So essentially the problem we are facing is that we want to be able t now grab the user bio from firebase whenever the user goes to their account or taps on the button 
    
    
    func setupProfile() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                self.usernameLabel.text = dict["username"] as? String
                self.userBio.text = dict["userBio"] as? String
                // The reason we add this line of code above is because we wanted to when the user opens up the app again we wanted to be able to have the bio they had originally be saved to their profile when they pressed the save changes button
                print("The cat is out of the bag")
                print(self.usernameLabel.text)
                if let profileImageURL = dict["pic"] as? String {
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        DispatchQueue.main.async {
                            self.profileImage.image = UIImage(data:data!)
                        }
                    }).resume()
                    
                }
                
                
            }
        })
        
    }
    // So the  error we are facing as of now is that it is not grabbing the username value from firebase and implementing it into our username label text
    // We figured out the solution to the problem and the problem was that we were assigning auto uids to the new users and they were getting authenticated with a different uid meaning that there was a discrepancy within the user identifcation not being able to connect between the authenticated user and the database user
}
