//
//  LibraryWidgetsLiveActivity.swift
//  LibraryWidgets
//
//  Created by COBSCCOMP242P-062 on 2026-04-27.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LibraryWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LibraryWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LibraryWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LibraryWidgetsAttributes {
    fileprivate static var preview: LibraryWidgetsAttributes {
        LibraryWidgetsAttributes(name: "World")
    }
}

extension LibraryWidgetsAttributes.ContentState {
    fileprivate static var smiley: LibraryWidgetsAttributes.ContentState {
        LibraryWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LibraryWidgetsAttributes.ContentState {
         LibraryWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LibraryWidgetsAttributes.preview) {
   LibraryWidgetsLiveActivity()
} contentStates: {
    LibraryWidgetsAttributes.ContentState.smiley
    LibraryWidgetsAttributes.ContentState.starEyes
}
