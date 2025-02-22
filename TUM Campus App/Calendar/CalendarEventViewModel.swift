//
//  CalendarEventViewModel.swift
//  TUMCampusApp
//
//  Created by Tim Gymnich on 11.6.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import CalendarKit
import UIKit

final class CalendarEventViewModel: EventDescriptor {
    var dateInterval: DateInterval
    var isAllDay = false
    var text: String
    var attributedText: NSAttributedString?
    var color = UIColor.systemBlue {
        didSet {
            updateColors()
        }
    }
    var backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
    var textColor = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return UIColor(red: 28/255, green: 171/255, blue: 246/255, alpha: 1)
        default: return UIColor(red: 34/255, green: 126/255, blue: 177/255, alpha: 1)
        }

    }
    var secondaryTextColor = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return UIColor(red: 28/255, green: 171/255, blue: 246/255, alpha: 1)
        default: return UIColor(red: 34/255, green: 126/255, blue: 177/255, alpha: 1)
        }

    }
    var font = UIFont.boldSystemFont(ofSize: 12)
    var userInfo: Any?
    var lineBreakMode: NSLineBreakMode? = .byWordWrapping
    weak var editedEvent: EventDescriptor? {
        didSet {
            updateColors()
        }
    }

    init(dateInterval: DateInterval, text: String, attributedText: NSAttributedString? = nil, userInfo: Any? = nil) {
        self.dateInterval = dateInterval
        self.text = text
        self.attributedText = attributedText
        self.userInfo = userInfo
    }

    init?(event: CalendarEvent) {
        guard let startDate = event.startDate, let endDate = event.endDate, let title = event.title else { return nil }
        self.dateInterval = DateInterval(start: startDate, end: endDate)
        self.text = title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startTime = dateFormatter.string(from: startDate)
        let endTime = dateFormatter.string(from: endDate)
        
        let attributedTitle = NSMutableAttributedString(string: title + " (" + startTime + " - " + endTime + ")").font(.systemFont(ofSize: 12, weight: .bold)).color(textColor)
        if let location = event.location {
            let attributedLocation = NSMutableAttributedString(string: location).font(.systemFont(ofSize: 12, weight: .regular)).color(textColor)
            attributedTitle.append(NSAttributedString(string: "\n"))
            attributedTitle.append(attributedLocation)
        }
        if let description = event.descriptionText {
            let attributedLocation = NSMutableAttributedString(string: description).font(.systemFont(ofSize: 12, weight: .regular)).color(secondaryTextColor)
            attributedTitle.append(NSAttributedString(string: "\n\n"))
            attributedTitle.append(attributedLocation)
        }
        
        if let url = event.url {
            attributedTitle.append(NSAttributedString(string: "\n\n"))
            attributedTitle.append(NSAttributedString(string: url.absoluteString))
        }
        
        self.attributedText = attributedTitle
    }

    func makeEditable() -> CalendarEventViewModel {
      return CalendarEventViewModel(dateInterval: dateInterval, text: text, attributedText: attributedText, userInfo: userInfo)
    }

    func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.dateInterval = dateInterval
    }

    private func updateColors() {
        (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
    }

    private func applyStandardColors() {
        backgroundColor = color.withAlphaComponent(0.3)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        textColor = UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }

    private func applyEditingColors() {
        backgroundColor = color
        textColor = .white
    }

}
