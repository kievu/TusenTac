//
//  CollectionViewController.swift
//  ColletionViewTest2
//
//  Created by ingeborg ødegård oftedal on 18/02/16.
//  Copyright © 2016 ingeborg ødegård oftedal. All rights reserved.
//

import UIKit
import Foundation
import ResearchKit

class TaskListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ORKTaskViewControllerDelegate {
    
    @IBOutlet var collection: UICollectionView!
    @IBOutlet weak var settingsIcon: UIBarButtonItem!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var imageView: UIImageView!
    var img: UIImage!
    
    let icons = ["medication", "eating", "weight", "side-effects"]
    let taskListRows = TaskListRow.allCases
    
    /**
    When a task is completed, the `TaskListViewController` calls this closure
    with the created task.
    */
    var taskResultFinishedCompletionHandler: (ORKResult -> Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(UserDefaults.boolForKey(UserDefaultKey.CompletedOnboarding) == false){
            collection.userInteractionEnabled = false
            showOverlay()
        } else {
            collection.userInteractionEnabled = true
        }

        userAction(settingsIcon)

        collection.dataSource = self
        collection.delegate = self
  
        collection.registerNib(UINib(nibName: "TaskCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collection.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        animateSettingsIconWithDuration(1.7)
        
        UserDefaults.setBool(true, forKey: UserDefaultKey.CompletedOnboarding)
        print("Completed onboarding")
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentMedicineRegistration", name: "presentMedicineRegistration", object: nil)
    }
    
    
    func overlayTapped(sender: AnyObject){
        imageView.removeFromSuperview()
        collection.userInteractionEnabled = true
        
    }
    func showOverlay(){
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        if(screenHeight == 568){
            img = UIImage(named: "overlay-5")!
        }
        else if (screenHeight == 667){
            img = UIImage(named: "overlay-6")!
        }
        else if(screenHeight == 736){
            img = UIImage(named: "overlay-6plus")!
        }
        else {
            return
        }
        
        print("screenHeight \(screenHeight) screenWidth \(screenWidth)")
        
        imageView = UIImageView(image: img)
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(TaskListViewController.overlayTapped(_:)))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGest)
        
        self.navigationController?.view.addSubview(imageView)
        
    }
    func userAction(sender: AnyObject) {
        if let originView = sender.valueForKey("view") {
            let frame = originView.frame  //it's a UIBarButtonItem
            
            print("height \(frame.height)")
            print("width \(frame.width)")
            print("maxX \(frame.maxX)")
            print("minX \(frame.minX)")
            print("midX \(frame.midX)")
            print("maxY \(frame.maxY)")
            print("minY \(frame.minY)")
            print("midY \(frame.midY)")
            print(frame.origin.x)
            print(frame.origin.y)
            
        } else {
            let frame = sender.frame //it's a regular UIButton
        }
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskListRows.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TaskCollectionCell
        
        if indexPath.row == 0 {
            if let lastDosageTime = UserDefaults.objectForKey(UserDefaultKey.LastDosageTime) {
                let dateString = (lastDosageTime as! NSDate).toStringShortStyle()
                cell.lastDosageLabel.text = "Sist registrert \(dateString)"
                cell.lastDosageLabel.hidden = false
            }
            
        } else if indexPath.row == 2 {
            if let lastWeightTime = UserDefaults.objectForKey(UserDefaultKey.LastWeightTime) {
                let dateString = (lastWeightTime as! NSDate).toStringShortStyle()
                cell.lastDosageLabel.text = "Sist registrert \(dateString)"
                cell.lastDosageLabel.hidden = false
            }
        } else {
            cell.lastDosageLabel.hidden = true;
        }
        
        cell.iconImage.image = UIImage(named: icons[indexPath.row])
        cell.taskLabel.text = "\(taskListRows[indexPath.row])"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (view.frame.width/2)-5, height: (view.frame.height/2.5)-14)
    }
    
    // MARK: ORKTaskViewControllerDelegate
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        taskResultFinishedCompletionHandler?(taskViewController.result)
        
        let taskResult = taskViewController.result
        var dateNow = NSDate()
        
        switch reason {
        case .Completed:
            
            if let stepResults = taskResult.results as? [ORKStepResult] {
                for stepResult in stepResults {
                    for result in stepResult.results! {
                        if let questionStepResult = result as? ORKNumericQuestionResult {
                            if let answer = questionStepResult.answer  {
                                UserDefaults.setObject(answer, forKey: UserDefaultKey.Weight)
                                UserDefaults.setObject(taskResult.endDate, forKey: UserDefaultKey.LastWeightTime)
                            }
                        }
                        if taskResult.identifier == PillTask.identifier {
                            if let lastDosageTime = result as? ORKTimeOfDayQuestionResult {
                                if let timeAnswer = lastDosageTime.dateComponentsAnswer {
                                    dateNow = NSCalendar.currentCalendar().dateBySettingHour(
                                        timeAnswer.hour, minute: timeAnswer.minute, second: 0, ofDate: dateNow, options: NSCalendarOptions()
                                        )!
                                    UserDefaults.setObject(dateNow, forKey: UserDefaultKey.LastDosageTime)
                                }
                            }
                            if let choiceResult = result as? ORKChoiceQuestionResult {
                                if let _ = choiceResult.answer {
                                    if choiceResult.choiceAnswers![0] as! String == "now" {
                                        UserDefaults.setObject(dateNow, forKey: UserDefaultKey.LastDosageTime)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if taskResult.identifier != "SideEffectTask" {
                let csv = CSVProcesser(taskResult: taskResult)
                let csvData = csv.csv.dataUsingEncoding(NSUTF8StringEncoding)
                let ns = NettskjemaHandler()
                if csvData != nil {
                    ns.upload(csvData!)
                }
                /*let filename = getDocumentsDirectory().stringByAppendingPathComponent("test.txt")
                print(csv.csv)
                do {
                    try csv.csv.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    NSLog("Failed to write to disk.")
                }
                let ns = NettskjemaHandler()
                if let data = NSFileManager.defaultManager().contentsAtPath(filename) {
                    ns.upload(data)
                }*/
            }
            
        case .Failed, .Discarded, .Saved:
            break
            
        }
        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }*/
    
    func taskViewController(taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        stepViewController.continueButtonTitle = "Registrer"
        
        let identifier = stepViewController.step?.identifier
        if identifier == Identifier.WaitCompletionStep.rawValue {
            stepViewController.cancelButtonItem = nil
            delay(2.0, closure: { () -> () in
                if let stepViewController = stepViewController as? ORKWaitStepViewController {
                    stepViewController.goForward()
                }
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Present the task view controller that the user asked for.
        let taskListRow = taskListRows[indexPath.row]
        
        // Create a task from the `TaskListRow` to present in the `ORKTaskViewController`.
        let task = taskListRow.representedTask
        
        /*
        Passing `nil` for the `taskRunUUID` lets the task view controller
        generate an identifier for this run of the task.
        */
        let taskViewController = ORKTaskViewController(task: task, taskRunUUID: nil)
        
        // Make sure we receive events from `taskViewController`.
        taskViewController.delegate = self
        
        // Save eventual files to the document directory
        let documentURL = NSFileManager.defaultManager().URLsForDirectory(
            NSSearchPathDirectory.DocumentDirectory,
            inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as NSURL
        taskViewController.outputDirectory = documentURL
        
        
        /*
        We present the task directly, but it is also possible to use segues.
        The task property of the task view controller can be set any time before
        the task view controller is presented.
        */
        presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    func animateSettingsIconWithDuration(duration: Double) {
        let settingsView: UIView = settingsIcon.valueForKey("view") as! UIView
        UIView.animateWithDuration(duration, animations: {
            settingsView.transform = CGAffineTransformMakeRotation((90.0 * CGFloat(M_PI)) / 90.0)
        })
    }
    
    func presentMedicineRegistration() {
        let taskListRow = taskListRows[0]
        let task = taskListRow.representedTask
        let taskViewController = ORKTaskViewController(task: task, taskRunUUID: nil)
        self.navigationController!.presentViewController(taskViewController, animated: false, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        collection.reloadData()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            //1
            switch kind {
                //2
            case UICollectionElementKindSectionFooter:
                //3
                let footerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "UIOFooterView",
                    forIndexPath: indexPath)
                    as! FooterView
                
                return footerView
            default:
                //4
                fatalError("Unexpected element kind")
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}