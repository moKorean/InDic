//
// UIDownloadBar.m
// UIDownloadBar
//


#import "UIDownloadBar.h"

@implementation UIDownloadBar

@synthesize DownloadRequest,
DownloadConnection,
receivedData,
delegate,
percentComplete;


- (UIDownloadBar *)initWithURL:(NSURL *)fileURL progressBarFrame:(CGRect)frame timeout:(NSInteger)timeout delegate:(id<UIDownloadBarDelegate>)theDelegate {
    self = [super initWithFrame:frame];
    if(self) {
        self.delegate = theDelegate;
        bytesReceived = percentComplete = 0;
        localFilename = [[[fileURL absoluteString] lastPathComponent] copy];
        receivedData = [[NSMutableData alloc] initWithLength:0];
        self.progress = 0.0;
        self.backgroundColor = [UIColor clearColor];
        DownloadRequest = [[NSURLRequest alloc] initWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheDa ta timeoutInterval:timeout];
        DownloadConnection = [[NSURLConnection alloc] initWithRequest:DownloadRequest delegate:self startImmediately:YES];
        
        if(DownloadConnection == nil) {
            [self.delegate downloadBar:self didFailWithError:[NSError errorWithDomain:@"UIDownloadBar Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"NSURLConnection Failed", NSLocalizedDescriptionKey, nil]]];
        }
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
    
    NSInteger receivedLen = [data length];
    bytesReceived = (bytesReceived + receivedLen);
    
    if(expectedBytes != NSURLResponseUnknownLength) {
        self.progress = ((bytesReceived/(float)expectedBytes)*100)/100;
        percentComplete = self.progress*100;
    }
    
    [delegate downloadBarUpdated:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate downloadBar:self didFailWithError:error];
    [connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    expectedBytes = [response expectedContentLength];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate downloadBar:self didFinishWithData:self.receivedData suggestedFilename:localFilename];
    [connection release];
}


- (void)dealloc {
    [localFilename release];
    [receivedData release];
    [DownloadRequest release];
    [DownloadConnection release];
    [super dealloc];
}

@end