//
//  RFC3984.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/17/17.
//
//

import CBelledonneToolbox.port
import CBelledonneRTP.stringutils
import CMediaStreamer2.rfc3984
import class BelledonneRTP.Packet

/// Used to pack/unpack H264 nals as described in RFC3984
public final class Rfc3984Context {
    
    public typealias RawPointer = UnsafeMutablePointer<CMediaStreamer2.Rfc3984Context>
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer
    
    // MARK: - Initialization
    
    deinit {
        
        rfc3984_destroy(rawPointer)
    }
    
    public init() {
        
        guard let rawPointer = rfc3984_new()
            else { fatalError("Could not create object") }
        
        self.rawPointer = rawPointer
    }
    
    // MARK: - Accessors
    
    public var mode: Bool {
        
        @inline(__always)
        get { return rawPointer.pointee.mode.boolValue }
        
        @inline(__always)
        set { rawPointer.pointee.mode = bool_t(newValue) }
    }
    
    public var isSingleTimeAggregationPacketAEnabled: Bool {
        
        @inline(__always)
        get { return rawPointer.pointee.stap_a_allowed.boolValue }
        
        @inline(__always)
        set { rawPointer.pointee.stap_a_allowed = bool_t(newValue) }
    }
    
    public var maxSize: Int {
        
        @inline(__always)
        get { return Int(rawPointer.pointee.maxsz) }
        
        @inline(__always)
        set { rawPointer.pointee.maxsz = Int32(newValue) }
    }
    
    // MARK: - Methods
    
    /// Process NALUs and pack them into rtp payload.
    public func pack(nalu: Queue, rtp: Queue, ts: UInt) {
        
        rfc3984_pack(rawPointer, nalu.rawPointer, rtp.rawPointer, UInt32(ts))
    }
    
    /// Process incoming rtp data and output NALUs, whenever possible.
    ///
    /// - Parameter packet: A new H264 packet to process. 
    /// - Parameter nalu: A `Queue` into which a frame ready to be decoded will be output, 
    /// in the form of a sequence of NAL units.
    public func unpack(packet: Packet, nalu: Queue) -> Rfc3984Status {
        
        let status = packet.withUnsafeRawPointer { rfc3984_unpack2(rawPointer, UnsafeMutablePointer($0), nalu.rawPointer) }
        
        return Rfc3984Status(status)
    }
}
