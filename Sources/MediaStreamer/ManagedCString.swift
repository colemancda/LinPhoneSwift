//
//  ManagedCString.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/6/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C.stdlib
#elseif os(Linux)
    import Glibc
#endif

internal final class ManagedCString {
    
    typealias RawPointer = UnsafeMutablePointer<UInt8>?
    
    typealias Getter = () -> (RawPointer)
    
    typealias Setter = (RawPointer) -> ()
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer = nil
    
    let getter: Getter
    
    let setter: Setter
    
    // MARK: - Initialization
    
    deinit {
        
        assert(getter() == rawPointer, "The targeted raw pointer has been externally modified")
        
        if let pointer = rawPointer {
            
            free(pointer)
        }
        
        setter(nil)
        
        assert(getter() == nil, "The raw pointer has not been freed")
    }
    
    init(getter: @escaping Getter, setter: @escaping Setter) {
    
        self.getter = getter
        self.setter = setter
    }
    
    var string: String? {
        
        willSet {  }
    }
}
