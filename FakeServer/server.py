#!/usr/bin/env python
# -*- coding: utf-8 -*-
from twisted.web import server, resource
from twisted.internet import reactor, protocol
from twisted.protocols import sip
import json
import time
from datetime import datetime
from pcapfile import savefile

IP = '127.0.0.1'

audio_testcap = open('audio_in.pcap', "rb")
audio_capfile = savefile.load_savefile(audio_testcap, verbose=True)

video_testcap = open('video_in.pcap', "rb")
video_capfile = savefile.load_savefile(video_testcap, verbose=True)


class Simple(resource.Resource):
    isLeaf = True
    def render_GET(self, request):
        print str(datetime.now()), request

        if request.uri.startswith("/doorbots/history"):
            request.responseHeaders.addRawHeader(b"content-type", b"application/json")
            return json.dumps([])

        elif request.uri.startswith("/ring_devices"):
            request.responseHeaders.addRawHeader(b"content-type", b"application/json")
            return json.dumps({"doorbots":[],"authorized_doorbots":[],"stickup_cams":[],"chimes":[]})

        elif request.uri.startswith("/dings/active"):
            request.responseHeaders.addRawHeader(b"content-type", b"application/json")
            return json.dumps([{
                "id": int(round(time.time() * 1000)),
                "state": "connected",
                "doorbot_id": 1,
                "doorbot_description": "Test",
                "device_kind": "doorbell",
                "protocol": "sip",
                "sip_server_ip": IP,
                "sip_server_port": 8081,
                "sip_server_tls": False,
                "sip_session_id": 2,
                "sip_from": "sip:1-2@" + IP + ":8081",
                "sip_to": "sip:1-2@" + IP + ":8081;transport=tcp",
                "kind": "motion"
                }])

        elif request.uri.startswith("/time"):
            request.responseHeaders.addRawHeader(b"content-type", b"application/json")
            return json.dumps({"now":int(round(time.time() * 1000))})

        return "Error"

    def render_PUT(self, request):
        print str(datetime.now()), request
        return "Error"

    def render_POST(self, request):
        print str(datetime.now()), request

        if request.uri.startswith("/session"):
            request.content.seek(0,0)
            print json.loads(request.content.read())

            request.responseHeaders.addRawHeader(b"content-type", b"application/json")
            return json.dumps({
                "profile":{
                    "features":{}, 
                    "authentication_token": "nothing", 
                    "email": "test@user.com", 
                    "first_name": "Pepe", 
                    "last_name": "Muleiro", 
                    "id": 1, 
                    "push_notification_channel": "apn"
                }
            })

        return "Error"

    def render_DELETE(self, request):
        print str(datetime.now()), request
        return "Error"

    def render_PATCH(self, request):
        print str(datetime.now()), request

        if request.uri.startswith("/device"):
            request.responseHeaders.addRawHeader(b"content-type", b"application/json")
            return json.dumps({})

        return "Error"

class FakeSIP(sip.Base):
    addr = None

    def dataReceived(self, data):
        self.datagramReceived(data, (self.addr.host, self.addr.port))

    def sendMessage(self, destURL, message):
        self.transport.write(message.toString())

    def connectionLost(self, reason):
        pass

    def handle_request(self, message, addr):
        print str(datetime.now()), message.method
        f = getattr(self, "handle_%s_request" % message.method, None)
        if f is None:
            f = self.handle_request_default
        
        f(message, addr)

    def handle_INVITE_request(self, message, addr):
        response = self.responseFromRequest(200, message)
        response.headers["Contact"] = ["<sip:3003@" + IP + ":8081;transport=tcp>"]
        response.headers["Content-Type"] = ["application/sdp"]
        response.headers["Content-Disposition"] = ["session"]
        response.body = """v=0
o=FreeSWITCH 1427284875 1427284876 IN IP4 %(ip)s
s=FreeSWITCH
c=IN IP4 %(ip)s
t=0 0
m=audio 30510 RTP/AVP 0 101
a=rtpmap:0 PCMU/8000
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-16
a=ptime:20
a=rtcp:30511 IN IP4 %(ip)s
m=video 30304 RTP/AVP 97
a=rtpmap:97 H264/90000
a=fmtp:97 profile-level-id=42801F
a=rtcp:30305 IN IP4 %(ip)s
""".replace('\n', '\r\n') % {'ip': IP}
        response.headers["Content-Length"] = [str(len(response.body))]
        self.deliverResponse(response)

    def handle_INFO_request(self, message, addr):
        response = self.responseFromRequest(200, message)
        response.headers["Content-Length"] = ["0"]
        
        self.deliverResponse(response)

    def handle_BYE_request(self, message, addr):
        response = self.responseFromRequest(200, message)
        response.headers["Content-Length"] = ["0"]
        
        self.deliverResponse(response)

    def handle_request_default(self, message, (srcHost, srcPort)):
        print message.method
        print message

    def deliverResponse(self, responseMessage):
        """Deliver response.
        Destination is based on topmost Via header."""
        destVia = sip.parseViaHeader(responseMessage.headers["via"][0])
        # XXX we don't do multicast yet
        host = destVia.received or destVia.host
        port = destVia.rport or destVia.port or self.PORT

        destAddr = sip.URL(host=host, port=port)
        print str(datetime.now()), responseMessage.toString()
        self.sendMessage(destAddr, responseMessage)

    def responseFromRequest(self, code, request):
        """Create a response to a request message."""
        response = sip.Response(code)
        for name in ("via", "to", "from", "call-id", "cseq"):
            response.headers[name] = request.headers.get(name, [])[:]
        return response

class FakeSIPFactory(protocol.Factory):
    def buildProtocol(self, addr):
        new = FakeSIP()
        new.addr = addr
        return new

class RTCPHandler(protocol.DatagramProtocol):
    def datagramReceived(self, data, addr):
        print str(datetime.now()), "Have RTCP data"

class PcapReplay(protocol.DatagramProtocol):
    i = 0
    started = False
    pcap = None

    def __init__(self, pcap):
        self.pcap = pcap

    def datagramReceived(self, data, addr):
        if self.started:
            return

        print str(datetime.now()), "Start pushing RTP data", addr
        self.started = True
        self.pushDataIndex(918, addr)

    def pushDataIndex(self, index, addr):
        packet = self.pcap.packets[index]
        next_packet = self.pcap.packets[index+1] if index+1 < len(self.pcap.packets) else None
        self.transport.write(packet.raw()[42:], addr)

        if next_packet is not None:
            if next_packet.timestamp - packet.timestamp == 0:
                timedif = (next_packet.timestamp_ms - packet.timestamp_ms) / 1000000.0
            else:
                timedif = (next_packet.timestamp_ms + (1000000 - packet.timestamp_ms)) / 1000000.0
                timedif += next_packet.timestamp - packet.timestamp - 1

            reactor.callLater(timedif, self.pushDataIndex, index+1, addr)
        else:
            print str(datetime.now()), "Finished pushing RTP data"
            self.started = False


reactor.listenTCP(8080, server.Site(Simple()))
reactor.listenTCP(8081, FakeSIPFactory())
#reactor.listenUDP(8082, FakeSIP())
reactor.listenUDP(30510, PcapReplay(audio_capfile))
reactor.listenUDP(30511, RTCPHandler())
reactor.listenUDP(30304, PcapReplay(video_capfile))
reactor.listenUDP(30305, RTCPHandler())

reactor.run()
