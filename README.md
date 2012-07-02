# System Configuration Network Reachability Kit

SCNetworkReachabilityKit provides Objective-C wrappers for the network reachability API found in Apple's System Configuration framework. You can find an iOS-based sample application at [GitHub](https://github.com/royratcliffe/SCNetworkReachability).

## Aims and Objectives

This project aims to provide a multi-platform thread-aware network reachability toolkit for Apple platforms. The basic problem: Apple's SystemConfiguration framework currently provides an entirely C-based synchronous API.

The project incorporates two targets: an OS X framework and an iOS static library. You can compile the project sources for iOS 4.3 and above, or for OS X 10.6 or above.

## Usage

How to use the framework or library? Start by instantiating an instance of `SCNetworkReachability`. Use `+networkReachabilityForInternet` for full Internet reachability; or use `+networkReachabilityForLinkLocal` for local wifi. You can then access the reachability flags immediately in order to determine some initial application behaviour modifications based on presence or lack of connectivity. Thereafter you register for `kSCNetworkReachabilityDidChangeNotification`s. These notifications pass updated reachability flags in the notification user information dictionary under the `kSCNetworkReachabilityFlagsKey` as an `NSNumber`. You can conveniently decode these flags using `-[networkReachableForFlags:]`; it answers one of `kSCNetworkNotReachable`, `kSCNetworkReachableViaWiFi` or `kSCNetworkReachableViaWWAN`. The network is reachable if _not_ equal to `kSCNetworkNotReachable`.

For example, set up your app delegate or other controller for detecting general Internet reachability using:

```objective-c
	SCNetworkReachability *internetReachability = [SCNetworkReachability networkReachabilityForInternet];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self
			   selector:@selector(internetReachabilityDidChange:)
				   name:kSCNetworkReachabilityDidChangeNotification object:nil];
	
	// Before starting up the notifications, ask for the reachability flags,
	// waiting if necessary. Post a notification with the initial reachability
	// flags if available. This first request for flags blocks the calling
	// thread.
	SCNetworkReachabilityFlags flags;
	if ([internetReachability getFlags:&flags])
	{
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:flags]
															 forKey:kSCNetworkReachabilityFlagsKey];
		[center postNotificationName:kSCNetworkReachabilityDidChangeNotification
							  object:internetReachability
							userInfo:userInfo];
	}
	[internetReachability startNotifier];
```

Your controller can then handle the notifications about Internet reachability like this.

```objective-c
	// Turn reachability flags into a localised string, something that the
	// interface can display for the user.
	SCNetworkReachability *reachability = [notification object];
	NSNumber *flagsNumber = [[notification userInfo] objectForKey:kSCNetworkReachabilityFlagsKey];
	SCNetworkReachabilityFlags flags = [flagsNumber unsignedIntValue];
	SCNetworkReachable reachable = [reachability networkReachableForFlags:flags];
	NSString *reachableString;
	switch (reachable)
	{
		case kSCNetworkNotReachable:
			reachableString = NSLocalizedString(@"Not Reachable", nil);
			break;
		case kSCNetworkReachableViaWiFi:
			reachableString = NSLocalizedString(@"Reachable Via Wi-Fi", nil);
			break;
		case kSCNetworkReachableViaWWAN:
			reachableString = NSLocalizedString(@"Reachable Via WWAN", nil);
			break;
		default:
			reachableString = nil;
	}
```

### Linking With iOS Apps

Link with iOS applications as normal. But do _not_ forget to also link against the `SystemConfiguration.framework`. Add this to your list of libraries against which to link, in addition to the static library `libSCNetworkReachabilityKit.a`.

## Based on Open-Source Sample

The SCNetworkReachabilityKit is largely based on Apple's open-source sample project “Reachability.” Apple's sample does not however properly handle cross-platform compilation. It assumes an iOS platform. Consequently, compiling for OS X fails.

In addition, Apple's sample does not include any unit testing, nor _directly_ addresses the threading issue. Apple's SystemConfiguration.framework is entirely synchronous. That means asking for the network reachability flags blocks the current thread until reachability resolves. This may take a second or two—well within range to trigger the iOS watchdog.

Much better if reachability notifies the application. The framework provides such an interface. However, Apple's sample code does not let you use the notification-supplied reachability flags; you still need to invoke the blocking method.

In contrast, this kit factors out the reachable status allowing applications to receive notifications fully loaded with the necessary reachability information and assess the reachable status without ever accessing the underlying _synchronous_ API. Asynchronous reachability is the goal.

## Future Directions

This work might become redundant. Apple may provide their own Objective-C wrappers at some point in the future. That makes this project a little presumptuous, but useful in the meantime.
