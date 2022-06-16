//
//  Logger.swift
//  NumberPlaceMaker
//
//  Created by tosakakun on 2017/05/01.
//

import Foundation
import os

extension OSLogType: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case OSLogType.info:
            return "INFO"
        case OSLogType.debug:
            return "DEBUG"
        case OSLogType.error:
            return "ERROR"
        case OSLogType.fault:
            return "FAULT"
        default:
            return "DEFAULT"
            
        }
        
    }
    
}

public enum Logger {
    
    private static let logger = os.Logger(subsystem: "com.misubo.numberplacemaker", category: "lib")
    
    public static var logLevel = OSLogType.info
    
    public static func debug<T: CustomDebugStringConvertible>(message: T, function: String = #function, line: Int = #line) {
        if logLevel == .debug {
            logger.debug("[\(OSLogType.debug)][\(function)][\(line)] \(String(reflecting: message))")
        }
    }
    
    public static func info<T: CustomDebugStringConvertible>(message: T, function: String = #function, line: Int = #line) {
        if logLevel == .debug || logLevel == .info {
            logger.info("[\(OSLogType.info)][\(function)][\(line)] \(String(reflecting: message))")
        }
    }
    
    public static func notice<T: CustomDebugStringConvertible>(message: T, function: String = #function, line: Int = #line) {
        if logLevel == .debug || logLevel == .info || logLevel == .default {
            logger.notice("[\(OSLogType.default)][\(function)][\(line)] \(String(reflecting: message))")
        }
    }
    
    public static func error<T: CustomDebugStringConvertible>(message: T, function: String = #function, line: Int = #line) {
        if logLevel == .debug || logLevel == .info || logLevel == .default || logLevel == .error {
            logger.error("[\(OSLogType.error)][\(function)][\(line)] \(String(reflecting: message))")
        }
    }
    
    public static func fault<T: CustomDebugStringConvertible>(message: T, function: String = #function, line: Int = #line) {
        if logLevel == .debug || logLevel == .info || logLevel == .default || logLevel == .error || logLevel == .fault {
            logger.fault("[\(OSLogType.fault)][\(function)][\(line)] \(String(reflecting: message))")
        }
    }

}
