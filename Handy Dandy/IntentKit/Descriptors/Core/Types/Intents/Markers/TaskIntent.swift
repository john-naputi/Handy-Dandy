//
//  TaskIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/31/25.
//

protocol TaskIntent : Intent {}

protocol PlanTaskIntent : TaskIntent {}

protocol ChecklistTaskIntent : TaskIntent {}
