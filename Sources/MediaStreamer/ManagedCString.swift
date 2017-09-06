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

internal final class ManagedCString <CString> {
    
    typealias RawPointer = UnsafeMutablePointer<CChar>?
    
    typealias DidChange = (CString) -> ()
    
    // MARK: - Properties
    
    @_versioned
    internal private(set) var rawPointer: RawPointer = nil
    
    @_versioned
    internal var string: String? = nil {
        
        didSet { stringChanged() }
    }
    
    internal var didChange: DidChange
    
    // MARK: - Initialization
    
    deinit {
        
        if let pointer = rawPointer {
            
            free(pointer)
        }
    }
    
    init(didChange: @escaping DidChange) {
        
        self.didChange = didChange
    }
    
    private func stringChanged() {
        
        // free C string of old value
        if let oldPointer = rawPointer {
            
            free(oldPointer)
        }
        
        // set new string buffer
        self.rawPointer = string?.withCString { strdup($0) }
        
        // call callback
        let cString = unsafeBitCast(rawPointer, to: CString.self)
        didChange(cString)
    }
}
