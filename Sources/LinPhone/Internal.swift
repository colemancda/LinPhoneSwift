//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C.stdlib
#elseif os(Linux)
    import Glibc
#endif

import typealias CLinPhone.bool_t
import typealias CLinPhone.LinphoneStatus

internal extension String {
    
    /// Get a constant string.
    init?(lpCString cString: UnsafePointer<Int8>?) {
        
        guard let cString = cString
            else { return nil }
        
        self.init(cString: cString)
    }
    
    /// Get a string from a C string `CChar` buffer that needs to be freed.
    init?(lpCString cString: UnsafeMutablePointer<Int8>?) {
        
        guard let cString = cString
            else { return nil }
        
        defer { free(cString) }
        
        self.init(cString: cString)
    }
}

internal extension CLinPhone.bool_t {
    
    @inline(__always)
    init(_ bool: Bool) {
        
        self = bool ? 1 : 0
    }
    
    var boolValue: Bool {
        
        @inline(__always)
        get { return self > 0 }
    }
}

internal extension LinphoneStatus {
    
    static var success: LinphoneStatus { return 0 }
    
    static var error: LinphoneStatus { return -1 }
}

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
