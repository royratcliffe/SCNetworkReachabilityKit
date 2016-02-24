// SCNetworkReachabilityKitTests SCNetworkReachabilityKitTests.m
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "SCNetworkReachabilityKitTests.h"
#import "SCNetworkReachabilityFlags.h"
#import "SCNetworkReachability.h"

@implementation SCNetworkReachabilityKitTests

- (void)setUp
{
	linkLocalReachability = [SCNetworkReachability networkReachabilityForLinkLocal];
	internetReachability = [SCNetworkReachability networkReachabilityForInternet];
}

- (void)testStringFromNetworkReachabilityFlags
{
	XCTAssertEqualObjects(CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(0x00000000)), @"---------");
#if TARGET_OS_IPHONE
	XCTAssertEqualObjects(CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(0xffffffff)), @"WdlDiCcRt");
#else
	XCTAssertEqualObjects(CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(0xffffffff)), @"-dlDiCcRt");
#endif
	XCTAssertEqualObjects(CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(kSCNetworkReachabilityFlagsReachable)), @"-------R-");
}

- (void)testLinkLocalReachability
{
	XCTAssertNotNil(linkLocalReachability);
	SCNetworkReachabilityFlags flags;
	XCTAssertTrue([linkLocalReachability getFlags:&flags]);
	XCTAssertEqualObjects(CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(flags)), @"-d-----R-");
}

- (void)testLinkLocalReachable
{
	XCTAssertEqual([linkLocalReachability networkReachableForFlags:kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsIsDirect], (SCNetworkReachable)kSCNetworkReachableViaWiFi);
}

- (void)testLinkLocalNotReachable
{
	XCTAssertEqual([linkLocalReachability networkReachableForFlags:kSCNetworkReachabilityFlagsReachable], (SCNetworkReachable)kSCNetworkNotReachable);
	XCTAssertEqual([linkLocalReachability networkReachableForFlags:kSCNetworkReachabilityFlagsIsDirect], (SCNetworkReachable)kSCNetworkNotReachable);
}

- (void)testInternetReachability
{
	XCTAssertNotNil(internetReachability);
	SCNetworkReachabilityFlags flags;
	XCTAssertTrue([internetReachability getFlags:&flags]);
	XCTAssertEqualObjects(CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(flags)), @"--l----R-");
}

- (void)testInternetReachableViaWiFi
{
	SCNetworkReachabilityFlags reachableViaWiFiFlags[] =
	{
		kSCNetworkReachabilityFlagsReachable,
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsInterventionRequired,
		
		// The network is reachable even without connection being required and
		// without intervention just so long as the connection is on-traffic and
		// on-demand.
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsConnectionOnTraffic,
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsConnectionOnDemand,
	};
	for (NSUInteger i = 0; i < sizeof(reachableViaWiFiFlags)/sizeof(reachableViaWiFiFlags[0]); i++)
	{
		XCTAssertEqual([internetReachability networkReachableForFlags:reachableViaWiFiFlags[i]], (SCNetworkReachable)kSCNetworkReachableViaWiFi, @"Internet not reachable via wi-fi (%@)", CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(reachableViaWiFiFlags[i])));
	}
}

- (void)testInternetNotReachable
{
	SCNetworkReachabilityFlags notReachableFlags[] =
	{
		// Of course, zero flags is never reachable. As a very minimum, the
		// reachability flags must raise the Reachable flag. That makes some
		// sense.
		0x00000000,
		
		// Despite being ostensibly reachable with the Reachable flag raised,
		// the Internet remains unreachable if the connection requires some
		// intervention and connection is a requirement.
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsInterventionRequired,
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsInterventionRequired | kSCNetworkReachabilityFlagsConnectionOnTraffic,
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsInterventionRequired | kSCNetworkReachabilityFlagsConnectionOnDemand,
		
		kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsConnectionRequired,
	};
	for (NSUInteger i = 0; i < sizeof(notReachableFlags)/sizeof(notReachableFlags[0]); i++)
	{
		XCTAssertEqual([internetReachability networkReachableForFlags:notReachableFlags[i]], (SCNetworkReachable)kSCNetworkNotReachable, @"Internet reachable via wi-fi (%@)", CFBridgingRelease(SCNetworkReachabilityCFStringCreateFromFlags(notReachableFlags[i])));
	}
}

@end
