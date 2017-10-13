//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import typealias CLinPhone.LinphoneStatus

// MARK: - Assertions

internal extension LinphoneStatus {
    
    @inline(__always)
    func lpAssert(function: String = #function, file: StaticString = #file, line: UInt = #line) {
        
        assert(self == .success, lpAssertMessage(function: function, file: file, line: line), file: file, line: line)
    }
}

internal extension Bool {
    
    @inline(__always)
    func lpAssert(function: String = #function, file: StaticString = #file, line: UInt = #line) {
        
        assert(self, lpAssertMessage(function: function, file: file, line: line), file: file, line: line)
    }
}

internal extension Optional {
    
    @inline(__always)
    func lpAssert(function: String = #function, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        
        guard let value = self
            else { linphoneFatalError(function: function, file: file, line: line) } // not really assert
        
        return value
    }
}

@_silgen_name("_linphone_swift_fatal_error")
internal func linphoneFatalError(function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    
    fatalError(lpFatalErrorMessage(function: function, file: file, line: line), file: file, line: line)
}

@inline(__always)
func lpFatalErrorMessage(function: String = #function, file: StaticString = #file, line: UInt = #line) -> String {
    
    return "An internal Linphone exception occurred in \(function)"
}

@inline(__always)
func lpAssertMessage(function: String = #function, file: StaticString = #file, line: UInt = #line) -> String {
    
    return "A Linphone assertion failed in \(function)"
}
