//
//  Packet.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/30/17.
//
//

import CBelledonneRTP.stringutils

/// Linked List media packet that contains RTP data.
public final class Packet {
    
    // MARK: - Properties
    
    @_versioned
    internal private(set) var internalData = mblk_t()
    
    
}
