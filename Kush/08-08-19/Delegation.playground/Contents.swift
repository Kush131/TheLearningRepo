import Foundation

/// Delegate protocol that defines behavior a delegate should provide.
protocol CalendarDelegate: class { // Using the class keyword restricts the protocol to classes (which allows us to keep weak references of the delegate object)
    func calendar(_ calendar: Calendar, willDisplay year: Int)
    func calendar(_ calendar: Calendar, didSelect date: Date)
    func caledarShouldChangeYear(_ calendar: Calendar) -> Bool
}

/// Data source protocol that defines behavior a data source should provide.
protocol CalendarDataSource {
    func calendar(_ calendar: Calendar, eventsFor date: Date) -> [String]
    func calendar(_ calendar: Calendar, add event: String, to date: Date)
}

protocol ReminderPresenting {
    func yearChanged(to year: Int)
}

/// Class that delegates out responsibilities to a delegate object.
class Calendar {
    // Define our delegates
    weak var delegate: CalendarDelegate?
    var dataSource: CalendarDataSource?

    // Properties of Calendar
    var selectedDate: Date = Date()
    var currentYear: Int = 2019

    func changeDate(to date: Date) {
        selectedDate = date
        delegate?.calendar(self, didSelect: selectedDate)
        if let items = dataSource?.calendar(self, eventsFor: date) {
            print("Today's events are...")
            items.forEach { print($0) }
        }
        else {
            print("You have no events today")
        }
    }

    func changeYear(to year: Int) {
        if delegate?.caledarShouldChangeYear(self) ?? true {
            delegate?.calendar(self, willDisplay: year)
            currentYear = year
        }
    }

    /// Add an event
    func add(event: String) {
        // Since we are adding data, we will let the data source implement this however it wants.
        dataSource?.calendar(self, add: event, to: selectedDate)
    }
}

/// This is the typical way people use delegation: conform your object to multiple different delegate protocols and
/// roll with it. But this causes disorganization and the "Massive View Controller" problem. Instead, split the
/// responsibilities up and create two objects, one that is specifically used for a data source like below this
/// commented out block:

//class Reminders: CalendarDelegate, CalendarDataSource {
//
//    // Reminder properties
//    var title = "Year: 2019"
//    var calendar = Calendar()
//
//    init() {
//        calendar.delegate = self
//        calendar.dataSource = self
//    }
//
//    func calendar(_ calendar: Calendar, willDisplay year: Int) {
//        title = "Year: \(year)"
//    }
//
//    func calendar(_ calendar: Calendar, didSelect date: Date) {
//        print("You selected \(date)")
//    }
//
//    func caledarShouldChangeYear(_ calendar: Calendar) -> Bool {
//        return true
//    }
//
//    func calendar(_ calendar: Calendar, eventsFor date: Date) -> [String] {
//        return ["Task One", "Task Two"]
//    }
//
//    func calendar(_ calendar: Calendar, add event: String, to date: Date) {
//        print("Adding \(event) on \(date)")
//    }
//}

///// Calendar + Delegation object that will handle events from the Calendar object.
//class Reminders: CalendarDelegate {
//
//    // Reminder properties
//    var title = "Year: 2019"
//    var calendar = Calendar()
//
//    init() {
//        calendar.delegate = self
//        calendar.dataSource = RemindersCalendarDataSource()
//    }
//
//    func calendar(_ calendar: Calendar, willDisplay year: Int) {
//        title = "Year: \(year)"
//        /// This demonstrates an issue with splitting responsibilities. What if you split out the Calendar delegate
//        /// into its own object, but still wanted to set the title of the calendar? You would have to hold a reference
//        /// inside of the delegate. A solution that is available for pure swift: protocol extensions. You can also use
//        /// regular extensions (extend by constraining with Delegate protocol within the Reminders object), but it
//        /// doesn't reduce coupling (only a bit more organization).
//    }
//
//    func calendar(_ calendar: Calendar, didSelect date: Date) {
//        print("You selected \(date)")
//    }
//
//    func caledarShouldChangeYear(_ calendar: Calendar) -> Bool {
//        return true
//    }
//}

/// Calendar + Delegation object that will handle events from the Calendar object.
class Reminders: ReminderPresenting {

    // Reminder properties
    var title = "Year: 2019"
    var calendar = Calendar()

    init() {
        calendar.delegate = RemindersCalendarDelegate()
        calendar.dataSource = RemindersCalendarDataSource()
    }

    func yearChanged(to year: Int) {
        title = "Year: \(year)"
    }
}

class RemindersCalendarDelegate: CalendarDelegate {
    var parentController: Reminders?
    func calendar(_ calendar: Calendar, willDisplay year: Int) {
        parentController?.yearChanged(to: year)
    }

    func calendar(_ calendar: Calendar, didSelect date: Date) {
        print("You selected \(date)")
    }

    func caledarShouldChangeYear(_ calendar: Calendar) -> Bool {
        return true
    }
}

/// Delegation object that will handle data source events from the Calendar object.
class RemindersCalendarDataSource: CalendarDataSource {
    func calendar(_ calendar: Calendar, eventsFor date: Date) -> [String] {
        return ["Task One", "Task Two"]
    }

    func calendar(_ calendar: Calendar, add event: String, to date: Date) {
        print("Adding \(event) on \(date)")
    }
}

