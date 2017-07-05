//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import typealias CLinPhone.bool_t
import typealias CLinPhone.LinphoneStatus

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
        
        assert(self == .success, file: file, line: line)
        
        guard  else { linphoneFatalError(function: function, file: file, line: line) }
    }
}

internal extension Bool {
    
    @inline(__always)
    func lpAssert(function: String = #function, file: StaticString = #file, line: UInt = #line) {
        
        guard self else { linphoneFatalError(function: function, file: file, line: line) }
    }
}

internal extension Optional {
    
    @inline(__always)
    func lpAssert(function: String = #function, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        
        guard let value = self
            else { linphoneFatalError(function: function, file: file, line: line) }
        
        return value
    }
}

@_silgen_name("_linphone_swift_fatal_error")
internal func linphoneFatalError(function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    
    fatalError(errorMessage(function), file: file, line: line)
}

@inline(__always)
private func errorMessage(function: String = #function, file: StaticString = #file, line: UInt = #line) -> String {
    
    return "An internal Linphone exception occurred in \(function)"
}
