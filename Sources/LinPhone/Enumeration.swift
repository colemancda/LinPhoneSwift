//
//  InternalEnum.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

public protocol LinPhoneEnumeration: RawRepresentable {
    
    associatedtype LinPhoneType: RawRepresentable
    
    init?(_ linPhoneType: LinPhoneType)
    
    var linPhoneType: LinPhoneType { get }
}

public extension LinPhoneEnumeration where Self.RawValue == LinPhoneType.RawValue {
    
    @inline(__always)
    init(_ linPhoneType: LinPhoneType) {
        
        self.init(rawValue: linPhoneType.rawValue)!
    }
    
    var linPhoneType: LinPhoneType {
        
        @inline(__always)
        get { return LinPhoneType(rawValue: self.rawValue)! }
    }
}
