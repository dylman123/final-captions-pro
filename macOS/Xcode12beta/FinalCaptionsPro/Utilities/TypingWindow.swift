//
//  TypingWindow.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import Cocoa
import Combine
import SwiftUI

public func keyboardShortcut<Sender, Label>(
    _ key: KeyEquivalent,
    sender: Sender,
    modifiers: EventModifiers = .none,
    @ViewBuilder label: () -> Label
) -> some View where Label: View, Sender: Subject, Sender.Output == KeyEquivalent {
    Button(action: { sender.send(key) }, label: label)
        .keyboardShortcut(key, modifiers: modifiers)
}


public func keyboardShortcut<Sender>(
    _ key: KeyEquivalent,
    sender: Sender,
    modifiers: EventModifiers = .none
) -> some View where Sender: Subject, Sender.Output == KeyEquivalent {
    guard let nameFromKey = key.name else {
        return AnyView(EmptyView())
    }
    return AnyView(keyboardShortcut(key, sender: sender, modifiers: modifiers) {
        Text("\(nameFromKey)")
    })
}

extension KeyEquivalent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.character == rhs.character
    }
}

extension KeyEquivalent {
    var lowerCaseName: String? {
        if self.character.isLetter {
            return String(self.character)
        }
        switch self {
        case .downArrow: return "downArrow"
        case .upArrow: return "upArrow"
        case .leftArrow: return "leftArrow"
        case .rightArrow: return "rightArrow"
        case .return: return "returnKey"
        case .tab: return "tab"
        case .space: return "spacebar"
        case .delete: return "delete"
        case .deleteForward: return "fwdDelete"
        case .escape: return "escape"
        case "+": return "plus"
        case "-": return "minus"
        default: return nil
        }
    }

    var name: String? {
        lowerCaseName//?.capitalizingFirstLetter()
    }
}

public extension EventModifiers {
    static let none = Self()
}

//extension String {
//    func capitalizingFirstLetter() -> String {
//      return prefix(1).uppercased() + self.lowercased().dropFirst()
//    }
//
//    mutating func capitalizeFirstLetter() {
//      self = self.capitalizingFirstLetter()
//    }
//}

extension KeyEquivalent: CustomStringConvertible {
    public var description: String {
        name ?? "\(character)"
    }
}

public typealias KeyInputSubject = PassthroughSubject<KeyEquivalent, Never>

public final class KeyInputSubjectWrapper: ObservableObject, Subject {
    public func send(_ value: Output) {
        objectWillChange.send(value)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        objectWillChange.send(completion: completion)
    }
    
    public func send(subscription: Subscription) {
        objectWillChange.send(subscription: subscription)
    }
    

    public typealias ObjectWillChangePublisher = KeyInputSubject
    public let objectWillChange: ObjectWillChangePublisher
    public init(subject: ObjectWillChangePublisher = .init()) {
        objectWillChange = subject
    }
}

// MARK: Publisher Conformance
public extension KeyInputSubjectWrapper {
    typealias Output = KeyInputSubject.Output
    typealias Failure = KeyInputSubject.Failure
    
    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
        objectWillChange.receive(subscriber: subscriber)
    }
}
