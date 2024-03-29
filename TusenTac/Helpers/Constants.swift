//
//  Constants.swift
//  Mathys
//
//  Created by ingeborg ødegård oftedal on 15/12/15.
//  Copyright © 2015 ingeborg ødegård oftedal. All rights reserved.
//

import UIKit

let UserDefaults = NSUserDefaults.standardUserDefaults()

struct Color {
    static let primaryColor = UIColor(red: 0, green: 176/255, blue: 173/255, alpha: 1)
    static let secondaryColor = UIColor.lightGrayColor()
}

struct Notifications {
    static let snoozeDelayInMinutes = 60
    static let weightTimeUnit = NSCalendarUnit.Day
    static let weightTimeValue = 3
    static let alertBody = "Du har en ny oppgave å gjøre."
}
struct Configuration {
    static let contactMailAddress = "anders.asberg@farmasi.uio.no"
}

struct UserDefaultKey {
    static let medicineRegistration = "MedicineRegistration"
    static let weightRegistration = "WeightRegistration"
    static let morningTime = "TusenTacMorningTime"
    static let nightTime = "TusenTacNightTime"
    static let weightTime = "TusenTacWeightTime"
    static let morningDosage = "TusenTacMorningDosage"
    static let nightDosage = "TusenTacNightDosage"
    static let earlierDosage = "TusenTacEarlierDosage"
    static let timeOfDay = "TimeOfDay"
    static let dosage = "Dosage"
    
    static let hasLaunchedBefore = "HasLaunchedBefore"
    static let UUID = "UUID"
    static let testModeEnabled = "TestModeEnabled"
    
    static let NotificationsEnabled = "NotificationsEnabled"
    static let notificationType = "NotificationType"
    
    static let CompletedOnboarding = "CompletedOnboarding"
    
    static let overlayShown = "OverlayShown"
    
    static let Weight = "Weight"
    static let LastWeightTime = "LastWeightTime"
    static let LastDosageTime = "LastDosageTime"
    
    static let morningSwitchOn = "MorningSwitchOn"
    static let nightSwitchOn = "NightSwitchOn"
    static let weightSwitchOn = "WeightSwitchOn"
    static let passcodeSwitchOn = "PasscodeSwitchOn"
    
    static let hasSendtMorningNotification = "HasSendtMorningNotification"
    static let hasSendtNightNotification = "HasSendtNightNotification"
    static let hasSendtWeightNotification = "HasSendtWeightNotification"
}

struct Encrypted {
    static let account = "user"
    static let studyID = "StudyID"
}