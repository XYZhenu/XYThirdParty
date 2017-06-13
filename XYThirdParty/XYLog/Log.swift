//
//  Log.swift
//  shell
//
//  Created by xieyan on 2017/3/15.
//  Copyright © 2017年 xieyan. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
func DLogVerbose(_ message:String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    let name = file.description.components(separatedBy: "/").last!
    DDLogVerbose("File \(name) Func \(function) Line \(line) \(message)")
}
func DLogDebug(_ message:String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    let name = file.description.components(separatedBy: "/").last!
    DDLogDebug("File \(name) Func \(function) Line \(line) \(message)")
}
func DLogInfo(_ message:String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    let name = file.description.components(separatedBy: "/").last!
    DDLogInfo("File \(name) Func \(function) Line \(line) \(message)")
}
func DLogWarn(_ message:String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    let name = file.description.components(separatedBy: "/").last!
    DDLogWarn("File \(name) Func \(function) Line \(line) \(message)")
}
func DLogError(_ message:String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    let name = file.description.components(separatedBy: "/").last!
    DDLogError("File \(name) Func \(function) Line \(line) \(message)")
}
