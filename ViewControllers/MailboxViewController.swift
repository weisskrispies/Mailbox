//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Patrick Weiss on 5/19/15.
//  Copyright (c) 2015 Patrick Weiss. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var rescheduleImageView: UIImageView!
    @IBOutlet weak var assignToListImageView: UIImageView!

    @IBOutlet weak var rightIconView: UIView!
    @IBOutlet weak var rescheduleIconImageView: UIImageView!
    @IBOutlet weak var assignToListIconImageView: UIImageView!
    @IBOutlet weak var leftIconView: UIView!
    @IBOutlet weak var archiveIconImageView: UIImageView!
    @IBOutlet weak var deleteIconImageView: UIImageView!
    
    var initialCenter: CGPoint!
    var feedViewStartingPoint: CGPoint!
    var feedViewShiftedUp: CGPoint!
    var rightIconStartingPoint: CGPoint!
    var leftIconStartingPoint: CGPoint!

    //Colors
    let mailboxGreen: UIColor = UIColor(red: 136/255, green: 208/255, blue: 98/255, alpha: 1)
    let mailboxRed: UIColor = UIColor(red: 220/255, green: 97/255, blue: 49/255, alpha: 1)
    let mailboxYellow: UIColor = UIColor(red: 250/255, green: 207/255, blue: 61/255, alpha: 1)
    let mailboxBrown: UIColor = UIColor(red: 209/255, green: 166/255, blue: 122/255, alpha: 1)
    let mailboxGrey: UIColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
    let mailboxBlue: UIColor = UIColor(red: 112/255, green: 197/255, blue: 224/255, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: 320, height: 1367)

        rescheduleImageView.alpha = 0
        assignToListImageView.alpha = 0
        
        assignToListIconImageView.alpha = 0
        deleteIconImageView.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSwipeMessage(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(view)
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            initialCenter = messageImageView.center
            feedViewStartingPoint = feedImageView.center
            rightIconStartingPoint = rightIconView.center
            leftIconStartingPoint = leftIconView.center

        } else if sender.state == UIGestureRecognizerState.Changed {

            messageImageView.center = CGPoint(x: translation.x + initialCenter.x, y: initialCenter.y)
            archiveIconImageView.alpha = (translation.x / 60)
            rescheduleIconImageView.alpha = (translation.x / -60)
            
            // minor pan
            if translation.x < 60 && translation.x > 60 {
                messageBackgroundView.backgroundColor = mailboxGrey

            // archive
            } else if translation.x > 60 && translation.x < 190 {
                println("Archive me?")
                self.hideRightIcons()
                archiveIconImageView.alpha = 1
                deleteIconImageView.alpha = 0
                messageBackgroundView.backgroundColor = mailboxGreen
                leftIconView.center = CGPoint(x: leftIconStartingPoint.x + translation.x - 60 , y: leftIconStartingPoint.y)

            // delete
            } else if translation.x > 190 {
                println("Delete me?")
                deleteIconImageView.alpha = 1
                archiveIconImageView.alpha = 0
                self.hideRightIcons()
                messageBackgroundView.backgroundColor = mailboxRed
                leftIconView.center = CGPoint(x: leftIconStartingPoint.x + translation.x - 60 , y: leftIconStartingPoint.y)
            
            // reschedule
            } else if translation.x < -60 && translation.x > -190 {
                println("Reschedule me?")
                self.hideLeftIcons()
                rescheduleIconImageView.alpha = 1
                assignToListIconImageView.alpha = 0
                messageBackgroundView.backgroundColor = mailboxYellow
                rightIconView.center = CGPoint(x: rightIconStartingPoint.x + translation.x + 60 , y: rightIconStartingPoint.y)

            // list
            } else if translation.x < -190 {
                println("Assign me to a list?")
                self.hideLeftIcons()
                rescheduleIconImageView.alpha = 0
                assignToListIconImageView.alpha = 1
                messageBackgroundView.backgroundColor = mailboxBrown
                rightIconView.center = CGPoint(x: rightIconStartingPoint.x + translation.x + 60 , y: rightIconStartingPoint.y)

            } else {
                messageBackgroundView.backgroundColor = mailboxGrey
            }
            
            
            
        } else if sender.state == UIGestureRecognizerState.Ended {

            UIView.animateWithDuration(0.3, animations: { () -> Void in

                // get ready to archive
                if translation.x > 60 && translation.x < 190 {
                    if velocity.x > 0 {
                        println("Archiving!")
                        UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: { () -> Void in
                            self.messageImageView.center.x = 600
                            self.leftIconView.center.x = 600
                            self.feedImageView.center.y = self.feedViewStartingPoint.y - 86
                            }, completion: { (TRUE) -> Void in
                            self.resetInbox()
                        })
                    } else {
                        self.resetMessageView()
                    }

                // get ready to delete
                } else if translation.x > 190 {
                    if velocity.x > 0 {
                        println("Deleting!")
                        UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: { () -> Void in
                            self.messageImageView.center.x = 600
                            self.leftIconView.center.x = 600
                            self.feedImageView.center.y = self.feedViewStartingPoint.y - 86
                            }, completion: { (TRUE) -> Void in
                            self.resetInbox()
                        })
                    } else {
                        self.resetMessageView()
                    }
                
                // reschedule
                } else if translation.x < -60 && translation.x > -190 {
                    if velocity.x < 0 {
                        println("Rescheduling!")
                        UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: { () -> Void in
                            self.messageImageView.center.x = -600
                            self.rightIconView.center.x = -600
                            }, completion: { (TRUE) -> Void in
                            self.showRescheduleView()
                        })
                    } else {
                        self.resetMessageView()
                    }

                // assign to list
                } else if translation.x < -190 {
                    if velocity.x < 0 {
                        println("Assigning to a list!")
                        UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: { () -> Void in
                            self.messageImageView.center.x = -600
                            self.rightIconView.center.x = -600
                            }, completion: { (TRUE) -> Void in
                            self.showListOptionsView()
                        })
                    } else {
                        self.resetMessageView()
                    }
                    
                } else {
                    self.resetMessageView()
                }
                
                
            })
        }
        
    }

    // sends message back to it's original location
    func resetMessageView() {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut , animations: { () -> Void in
            self.messageImageView.center = self.initialCenter
            self.feedImageView.center = self.feedViewStartingPoint
            self.leftIconView.center = self.leftIconStartingPoint
            self.leftIconView.alpha = 1
            self.archiveIconImageView.alpha = 1
            self.deleteIconImageView.alpha = 0
            self.rightIconView.center = self.rightIconStartingPoint
            self.rightIconView.alpha = 1
            self.rescheduleIconImageView.alpha = 1
            self.assignToListIconImageView.alpha = 0
            }, completion: nil)
    }

    // resets Inbox to original messages
    func resetInbox() {
        UIView.animateWithDuration(0.01, delay: 0.6, options: nil, animations: { () -> Void in
            self.messageImageView.center.x = self.initialCenter.x
            self.leftIconView.center = self.leftIconStartingPoint
            self.leftIconView.alpha = 1
            self.archiveIconImageView.alpha = 1
            self.deleteIconImageView.alpha = 0
            self.rightIconView.center = self.rightIconStartingPoint
            self.rightIconView.alpha = 1
            self.rescheduleIconImageView.alpha = 1
            self.assignToListIconImageView.alpha = 0
            
            }, completion: nil)
        
        UIView.animateWithDuration(0.5, delay: 1, options: nil, animations: { () -> Void in
            self.feedImageView.center.y = self.feedViewStartingPoint.y
            }, completion: nil)
    }
    
    // Shows the rescheduling options
    func showRescheduleView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            println("Pop rescheduler")
            self.rescheduleImageView.alpha = 1
        })
        rescheduleImageView.userInteractionEnabled = Bool(true)
    }
    
    // Hides the rescheduling options
    func hideRescheduleView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            println("Hide rescheduler")
            self.rescheduleImageView.alpha = 0
            self.feedImageView.center.y = self.feedViewStartingPoint.y - 86
        })
        rescheduleImageView.userInteractionEnabled = Bool(true)
    }
    
    @IBAction func onTapToReschedule(sender: UITapGestureRecognizer) {
        hideRescheduleView()
        resetInbox()
    }

    // Shows the list options
    func showListOptionsView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            println("Pop list options")
            self.assignToListImageView.alpha = 1
        })
        assignToListImageView.userInteractionEnabled = Bool(true)
    }
    
    // Hides the list options
    func hideListOptionsView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            println("Hide list options")
            self.assignToListImageView.alpha = 0
            self.feedImageView.center.y = self.feedViewStartingPoint.y - 86
        })
        assignToListImageView.userInteractionEnabled = Bool(true)
    }
    
    @IBAction func onTapToSelectList(sender: UITapGestureRecognizer) {
        hideListOptionsView()
        resetInbox()
    }

    func hideLeftIcons() {
        self.leftIconView.alpha = 0
    }
    
    func hideRightIcons() {
        self.rightIconView.alpha = 0
    }
    

}
