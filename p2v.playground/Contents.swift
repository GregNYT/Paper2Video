//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


var a: Int?

let queue = DispatchQueue(label: "com.app.queue")
queue.sync {
    
    for  i in 0..<10 {
        
        print("Ⓜ️" , i)
        a = i
    }
}

print("After Queue \(a)")


PlaygroundPage.current.needsIndefiniteExecution = true
