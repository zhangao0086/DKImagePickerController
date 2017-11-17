//
//  DKBaseManager.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 17/11/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation

open class DKBaseManager: NSObject {
    
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    open func add(observer object: AnyObject) {
        self.observers.add(object)
    }
    
    open func remove(observer object: AnyObject) {
        self.observers.remove(object)
    }
    
    open func notify(with selector: Selector, object: AnyObject?) {
        self.notify(with: selector, object: object, objectTwo: nil)
    }
    
    open func notify(with selector: Selector, object: AnyObject?, objectTwo: AnyObject?) {
        if self.observers.count > 0 {
            DispatchQueue.main.async(execute: {
                for observer in self.observers.allObjects {
                    if observer.responds(to: selector) {
                        _ = observer.perform(selector, with: object, with: objectTwo)
                    }
                }
            })
        }
    }
    
}
