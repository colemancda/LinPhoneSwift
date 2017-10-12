//
//  BitMaskOption.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/6/17.
//

/// Enum represents a bit mask flag / option.
public protocol BitMaskOption: RawRepresentable, Hashable {
    
    /// All the cases of the enum.
    static var all: Set<Self> { get }
}

/// Convert Swift enums for option flags into their raw values OR'd.
public extension Collection where Iterator.Element: BitMaskOption, Iterator.Element.RawValue: BinaryInteger {
    
    var flags: Iterator.Element.RawValue {
        
        @inline(__always)
        get { return reduce(0, { $0 | $1.rawValue }) }
    }
}

public extension BitMaskOption where RawValue: BinaryInteger {
    
    /// Whether the enum case is present in the raw value.
    @inline(__always)
    func isContained(in rawValue: RawValue) -> Bool {
        
        return (self.rawValue & rawValue) != 0
    }
    
    @inline(__always)
    static func from(flags: RawValue) -> Set<Self> {
        
        return Set(Self.all.filter({ $0.isContained(in: flags) }))
    }
}
