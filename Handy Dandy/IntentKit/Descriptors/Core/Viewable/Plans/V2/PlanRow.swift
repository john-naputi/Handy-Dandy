//
//  PlanRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct PlanRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme
    private var isAxSize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }
    
    private var iconFont: Font {
        isAxSize ? .title : .title3
    }
    
    let plan: Plan
    
    private var summaryLine: String {
        switch plan.kind {
        case .singleTask:
            return "Single Task • \(plan.type.displayName)"
        case .taskList:
            let completed = plan.tasks.filter { $0.isComplete }.count
            let total = plan.tasks.count
            
            return "Task List • \(completed) of \(total) completed"
        case .checklist:
            let checklistCount = plan.checklists.count
            
            if checklistCount == 0 {
                return "Checklist • No Checklists"
            } else {
                return "Checklist • \(checklistCount) \(checklistCount == 1 ? "list" : "lists")"
            }
        }
    }
    
    var body: some View {
        let Stack = isAxSize
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
        : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
        
        Stack {
            Image(systemName: plan.type.symbol)
                .font(iconFont)
                .foregroundStyle(plan.type.tintColor)
                .alignmentGuide(.firstTextBaseline) { guide in
                    guide[.bottom]
                }
                .frame(minWidth: 25, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(plan.title)
                    .font(.headline)
                    .lineLimit(isAxSize ? 2 : 1)
                    .minimumScaleFactor(0.9)
                    .layoutPriority(1)
                
                Text(summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(isAxSize ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !plan.planDescription.isEmpty {
                    Text(plan.description())
                        .font(.body)
                        .lineLimit(isAxSize ? 4 : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let plan = Plan(title: "Grocery Shopping", kind: .checklist, type: .workout)
    PlanRow(plan: plan)
}
