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
    
    let icons = ["medication", "eating", "weight", "side-effects"]
    private let reuseIdentifier = "Cell"
    let nettskjema = NettskjemaHandler(scheme: .Answer)
    
    enum CollectionViewCellIdentifier: String {
        case Default = "Cell"
    }
    
    // MARK: Properties
    
    /**
    When a task is completed, the `TaskListViewController` calls this closure
    with the created task.
    */
    var taskResultFinishedCompletionHandler: (ORKResult -> Void)?
    
    let taskListRows = TaskListRow.allCases
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
  
        collection.registerNib(UINib(nibName: "TaskCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collection.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        animateSettingsIconWithDuration(1.7)
        
        UserDefaults.setBool(true, forKey: UserDefaultKey.CompletedOnboarding)
        print("Completed onboarding")
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentMedicineRegistration", name: "presentMedicineRegistration", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        // TODO: Update cell last registration label
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            if let lastDosage = UserDefaults.objectForKey(UserDefaultKey.LastDosageTime) {
                let dateString = (lastDosage as! NSDate).toStringShortStyle()
                cell.lastDosageLabel.text = "Forrige dose tatt \(dateString)"
            } else {
                cell.lastDosageLabel.text = ""
            }
        } else {
            cell.lastDosageLabel.hidden = true;
        }
        
        cell.iconImage.image = UIImage(named: icons[indexPath.row])
        cell.taskLabel.text = "\(taskListRows[indexPath.row])"
        cell.taskLabel.sizeToFit()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width/2)-5, height: (self.view.frame.height/2.5)-14)
    }
    
    // MARK: ORKTaskViewControllerDelegate
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {

        
        taskResultFinishedCompletionHandler?(taskViewController.result)
        
        
        let taskResult = taskViewController.result
        var dateNow = NSDate()
        var timePillTaken: NSDateComponents?
        
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
                        if let lastDosageTime = result as? ORKTimeOfDayQuestionResult {
                            if let timeAnswer = lastDosageTime.dateComponentsAnswer {
                                timePillTaken = timeAnswer
                            }
                        }
                    }
                }
            }
            
            // If the user registered that he/she took the pill earlier, set the date to the current date with those times.
            if timePillTaken != nil {
                dateNow = NSCalendar.currentCalendar().dateBySettingHour(
                    timePillTaken!.hour, minute: timePillTaken!.minute, second: 0, ofDate: dateNow, options: NSCalendarOptions()
                    )!
            }
            
            UserDefaults.setObject(dateNow, forKey: UserDefaultKey.LastDosageTime)
            
            if taskResult.identifier != "SideEffectTask" {
                let csv = CSVProcesser(taskResult: taskResult)
                print(csv.csv)
                nettskjema.setExtraField("\(taskViewController.result.identifier)", csv: "\(csv.csv)")
                nettskjema.submit()
            }
            
        case .Failed, .Discarded, .Saved:
            break
            
        }
        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
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
        taskViewController.outputDirectory = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as NSURL
        
        
        /*
        We present the task directly, but it is also possible to use segues.
        The task property of the task view controller can be set any time before
        the task view controller is presented.
        */
        presentViewController(taskViewController, animated: true, completion: nil)
        
        
    }
    
    func getNumberOfStepsCompleted(results: [ORKResult]) -> Int {
        return results.count
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
    
}