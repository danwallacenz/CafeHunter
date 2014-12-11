//
//  CafeViewController.swift
//  CafeHunter
//
//  Created by Daniel Wallace on 11/12/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit


    // This defines a protocol to which objects can conform to be told when the user is finished with the café detail view and it should be dismissed.
    // The optional tells the compiler that the method doesn’t have to be defined, leaving it up to the implementation class to decide whether it needs the method or not.

    // If you want optional methods in your protocol, you have to declare the protocol as @objc.
    // Marking the protocol as @objc enables Swift to put various runtime checks in place to check for conformance to the protocol and to check that various methods exist to support optional functionality.
@objc protocol CafeViewControllerDelegate {
    optional func cafeViewControllerDidFinish(
        viewController: CafeViewController)
}


class CafeViewController: UIViewController {

    // This defines a variable of type optional-Cafe. 
    // It will hold the café that the view controller is currently set up to display.
    var cafe: Cafe? {
        
        // Sets up a listener for when the variable changes. 
        // Variables can have willSet and didSet closures defined. 
        // The former is called just before the variable is set to a new value and the latter just after.
        didSet {
            self.setupWithCafe()
        }
    }
    // Marked as weak, which is standard practice for delegate properties to avoid retain cycles.
    weak var delegate: CafeViewControllerDelegate?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var streetLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var zipLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupWithCafe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func setupWithCafe() {
        
        //  This method is going to use properties that are IB outlets. 
        // Recall that these are implicitly unwrapped optionals. 
        // They only contain values once the view is loaded, so if this method is called before then, variables such as nameLabel and streetLabel won’t yet be set up.
        // You could check for the existence of each outlet directly, but that would be a lot of superfluous code. 
        // In this case, it’s simpler to check if the view is loaded.
        if !self.isViewLoaded() {
            return
        }
        
        // If there’s no café, then there’s nothing to set on the views. Only if there’s a café do you want to proceed.
        if let cafe = self.cafe {
            self.title = cafe.name
            self.nameLabel.text = cafe.name
            self.streetLabel.text = cafe.street
            self.cityLabel.text = cafe.city
            self.zipLabel.text = cafe.zip

        
        // Load the picture for the cafe by using an NSURLConnection.
            let request = NSURLRequest(URL: cafe.pictureURL)
            NSURLConnection.sendAsynchronousRequest(
                request, queue: NSOperationQueue.mainQueue())
                {
                    (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        let image = UIImage(data: data)
                        self.imageView.image = image
                }
        }

    }
    @IBAction private func back(sender: AnyObject) {
        self.delegate?.cafeViewControllerDidFinish?(self)
    }
}
