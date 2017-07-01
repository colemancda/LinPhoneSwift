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

public extension LinPhoneEnumeration where LinPhoneType.RawValue == Self.RawValue {
    
    init?(rawValue: RawValue) {
        
        guard let linphoneType = LinPhoneType(rawValue: rawValue)
            else { return nil }
        
        self.init(linphoneType)
    }
    
    var rawValue: RawValue {
        
        return linPhoneType.rawValue
    }
}
