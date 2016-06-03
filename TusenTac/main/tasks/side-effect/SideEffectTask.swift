//
//  SideEffectTask.swift
//  TusenTac
//
//  Created by ingeborg ødegård oftedal on 17/12/15.
//  Copyright © 2015 Paul Philip Mitchell. All rights reserved.
//

import Foundation
import ResearchKit

public var SideEffectTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    // INSTRUCTION STEP
   /* let instructionStep = ORKInstructionStep(identifier: Identifier.IntroStep.rawValue)
    instructionStep.title = "Registrering av bivirkninger".localized
    instructionStep.text = "På den neste siden kan du registrere eventuelle bivirkninger du har opplevd.".localized
    steps += [instructionStep]*/
    
    
    let textChoices = [ORKTextChoice(text: "Skjelving", value: "Skjelving"),
                       ORKTextChoice(text: "Diaré", value: "Diaré"),
                       ORKTextChoice(text: "Kvalme", value: "Kvalme"),
                       ORKTextChoice(text: "Hodepine", value: "Hodepine"),
                       ORKTextChoice(text: "Annet", value: "Annet"),
    ]
    
    let newSideEffectAnswer = ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: textChoices)
    
    let newSideEffectStep = ORKQuestionStep(identifier: Identifier.NewSideEffectStep.rawValue, title: "Registrering av bivirkninger".localized, answer: newSideEffectAnswer);
    
    //let italics = "nye/forverring"
    let quesText = "Velg en eller flere nye/forverring nye/forverring av bivirkninger"
    

    
    newSideEffectStep.text = quesText
    
    
    steps+=[newSideEffectStep]
    
    let oldSideEffectAnswer = ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: textChoices)
    
    let oldSideEffectStep = ORKQuestionStep(identifier: Identifier.OldSideEffectStep.rawValue, title:"Registrering av bivirkninger", answer: oldSideEffectAnswer);
    
    oldSideEffectStep.text = "Velg en eller flere bivirkninger som er blitt borte"
    
    steps+=[oldSideEffectStep]
    
    // SUMMARY STEP
    /*let summaryStep = ORKCompletionStep(identifier: Identifier.SummaryStep.rawValue)
    summaryStep.title = "Levert!".localized
    summaryStep.text = "Dine bivirkninger har blitt registrert.".localized
    steps += [summaryStep] */
    
    
    let waitStepIndeterminate = ORKWaitStep(identifier: Identifier.WaitCompletionStep.rawValue)
    waitStepIndeterminate.title = "Ferdig"
    waitStepIndeterminate.text = "Laster opp..."
    waitStepIndeterminate.indicatorType = ORKProgressIndicatorType.Indeterminate
    steps += [waitStepIndeterminate]
    
    return ORKOrderedTask(identifier: Identifier.SideEffectTask.rawValue, steps: steps)
    
}
