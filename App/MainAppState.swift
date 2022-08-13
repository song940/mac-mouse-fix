//
//  AppState.swift
//  tabTestStoryboards
//
//  Created by Noah Nübling on 2/11/22.
//

/// Don't overuse this or things will get messy!

import Cocoa
import ReactiveSwift

// MARK: Main State

@objc class MainAppState: NSObject {
    
    /// Declare singleton instance
    @objc static let shared = MainAppState()

    /// References
    
    @objc var tabViewController: TabViewController {
        let controller = NSApp.mainWindow?.contentViewController as! TabViewController
        return controller
    }
    @objc var appDelegate: AppDelegate {
        return NSApp.delegate as! AppDelegate
    }
    @objc var window: ResizingTabWindow? {
        return NSApp.mainWindow as? ResizingTabWindow
    }
    
    /// References to specific views
    ///     Are we sure we need this all these?? Seems a little messy to expose these globally
    @objc var remapTableController: RemapTableController? = nil
    @objc var remapTable: RemapTableView? { remapTableController?.view as? RemapTableView }
    @objc var addViewController: AddViewController? = nil
}

// MARK: Helper enabled state

@objc class EnabledState: NSObject, BindingSource {
    
    /// Binding source protocol
    var producer: SignalProducer<Bool, Never> {
        return signal.producer.prefix(value: isEnabled())
    }
    typealias Error = Never
    typealias Value = Bool
    
    /// Declare singleton instance
    @objc static let shared = EnabledState()
    
    /// Storage
    let signal: Signal<Bool, Never>
    let observer: Signal<Bool, Never>.Observer
    
    /// Init
    override init() {
        let (o, i) = Signal<Bool, Never>.pipe()
        signal = o
        observer = i
    }
    
    /// Main interface
    
    func enable() throws {
        var error: NSError?
        HelperServices.enableHelper(asUserAgent: true, error: &error)
        if error != nil { throw error! }
    }
    func disable() {
        HelperServices.enableHelper(asUserAgent: false, error: nil)
        observer.send(value: false)
    }
    func isEnabled() -> Bool {
        HelperServices.helperIsActive()
    }
    
    /// ObjC compat
    @objc func reactToDidBecomeEnabled() {
        observer.send(value: true)
    }
    
}
