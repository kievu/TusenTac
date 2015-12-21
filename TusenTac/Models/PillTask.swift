//
//  PillTask.swift
//  TusenTac
//
//  Created by ingeborg ødegård oftedal on 21/12/15.
//  Copyright © 2015 ingeborg ødegård oftedal. All rights reserved.
//


import Foundation
import ResearchKit

public var PillTask: ORKOrderedTask {
    let textChoiceOneText = NSLocalizedString("Tok pillen nå", comment: "")
    let textChoiceTwoText = NSLocalizedString("Tok pillen tidligere", comment: "")
    let textChoiceThreeText = NSLocalizedString("Choice 3", comment: "")
    
    // The text to display can be separate from the value coded for each choice:
    let textChoices = [
        ORKTextChoice(text: textChoiceOneText, value: "choice_1"),
        ORKTextChoice(text: textChoiceTwoText, value: "choice_2"),
        ORKTextChoice(text: textChoiceThreeText, value: "choice_3")
    ]
    
    let answerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices)
    
    let questionStep = ORKQuestionStep(identifier: Identifier.IntroStep.rawValue, title: "", answer: answerFormat)
    
    //questionStep.text = exampleDetailText
    
    return ORKOrderedTask(identifier: Identifier.IntroStep.rawValue, steps: [questionStep])

}
