


#import "SimplePingHelper.h"
#import "SimpleLinkNetwokUtil.h"
@interface SimplePingHelper(){
    
    SimplePing* _pingClient;
    NSDate* _dateReference;
    NSString *stopPing;
}
@property(nonatomic,retain) SimplePing* simplePing;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL sel;
@property(nonatomic, strong) void(^resultCallback)(NSString* latency);
- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel;
- (void)go;
@end

@implementation SimplePingHelper
@synthesize simplePing, target, sel;

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel {
	// The helper retains itself through the timeout function
	[[[SimplePingHelper alloc] initWithAddress:address target:target sel:sel]go];
}

#pragma mark - Init/dealloc

- (void)dealloc {
	self.simplePing = nil;
	self.target = nil;
	
}

- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel {
	if (self = [self init]) {
		self.simplePing = [SimplePing simplePingWithHostName:address];
		self.simplePing.delegate = self;
		self.target = _target;
		self.sel = _sel;
	}
	return self;
}

#pragma mark - Go

- (void)go {
	[self.simplePing start];
	[self performSelector:@selector(endTime) withObject:nil afterDelay:1];
    
    // This timeout is what retains the ping helper
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)killPing {
	[self.simplePing stop];
	self.simplePing = nil;
}


-(void) successPing {

	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pingKiller:) name:@"killPing" object:nil];
    if([stopPing isEqual:@"YES"]){
        [self killPing];
    }
	[target performSelector:sel withObject:[NSNumber numberWithBool:YES]];
    
}

- (void)failPing:(NSString*)reason {
	[target performSelector:sel withObject:[NSNumber numberWithBool:NO]];
}

 //Called 1s after ping start, to check if it timed out
- (void)endTime {
	if (self.simplePing) { // If it hasn't already been killed, then it's timed out
		[self failPing:@"timeout"];
	}
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
	[self.simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
	[self failPing:@"didFailWithError"];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
	// Eg they're not connected to any network
	 [self failPing:@"didFailToSendPacket"];
    
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {

    const struct IPHeader *cp =([packet bytes]);
    //print the size of the packet
    NSLog(@"%lu", (unsigned long)packet.length) ;
    NSString *ip=[ NSString stringWithFormat:@"%d.%d.%d.%d",cp->sourceAddress[0],cp->sourceAddress[1],cp->sourceAddress[2],cp->sourceAddress[3]];
    
    NSString *getDeviceNameFromIP = [NSString stringWithFormat:@"http://%@",ip];
  
    [SimpleLinkNetwokUtil getDeviceNameFromUrl:getDeviceNameFromIP ProductVersion:Product_Version_R2 WithCompletion:^(NSString *deviceName, NSString *errorMsg){
        if (errorMsg) {
            NSLog(@"Device name not found");
        }
        else{
            NSString *theReply=deviceName;
            theReply= [NSString stringWithFormat:@"%@,",theReply];
            theReply=[theReply stringByAppendingString:ip];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"pingResult" object: theReply];
            [self successPing];
            
        }
    }];

}

-(void)pingKiller:(NSNotification *)notification{
    stopPing= [notification object];
    NSLog(@"%@",stopPing);
    
}


@end
