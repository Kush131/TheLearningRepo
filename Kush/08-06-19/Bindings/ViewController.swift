//
//  ViewController.swift
//  PracticeBindings
//
//  Created by Kush, Ryan on 7/22/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

/// The view controller that will be displaying our content.
class ViewController: UIViewController {

    @IBOutlet weak var username: BoundTextField!

    var user = User(name: Observable("Ryan"))

    override func viewDidLoad() {
        super.viewDidLoad()
        /// Bind our username text field in the view to the user in the model layer.
        username.bind(to: user.name)
    }

}

/// A User we want to set the name of.
struct User {
    var name: Observable<String>
}

/// A new type that will allow us to "observe" any changes made to it. This is essentially the model layer.
class Observable<ObservedType> {

    /// Private internal value of the observable object. Kept private so the only way you can access
    /// it is through the public getter and setter below so we can notify when a value is changed.
    private var _value: ObservedType?

    public var value: ObservedType? {
        get {
            /// Getting doesn't modify, so just give back whatever interal value we have.
            return _value
        }
        set {
            /// If we set, we need to notify the view layer something has changed. So set + notify.
            _value = newValue
            valueChanged?(_value)
        }
    }

    /// Called whenever the view has an update they want to give us
    func bindingChanged(to newValue: ObservedType) {
        _value = newValue
        print("Value is now \(newValue)")
    }

    /// Our closure the view layer will use to notify us to change our internal value.
    var valueChanged: ((ObservedType?) -> ())?

    /// Just a generic initializer to set the internal private value.
    init(_ value: ObservedType) {
        _value = value
    }
}

/// A textfield that will be bound to a model object and update its contents if it
/// changes.
class BoundTextField: UITextField {

    /// A closure used when a value is changed on the text field. Called via the addTarget method below.
    var changedClosure: (() -> ())?

    /// If a value has changed, we want to tell the model layer to update it's value to the value we have.
    /// Needs to be a method since we have to set the target up when .editingChanged happens on the BoundTextField.
    @objc func valueChanged() {
        changedClosure?()
    }

    func bind(to observable: Observable<String>) {
        addTarget(self, action: #selector(BoundTextField.valueChanged), for: .editingChanged)

        /// Notify the model we have text we want to update it with.
        changedClosure = { [weak self] in
            observable.bindingChanged(to: self?.text ?? "")
        }

        /// Notify the view that we have text we want to update it with.
        observable.valueChanged = { [weak self] newValue in
            self?.text = newValue
        }
    }
}

