

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface MPRecordEncoder : NSObject
@property (nonatomic, readonly) NSString *path;

-(void)start:(CMSampleBufferRef)sampleBuffer;

+ (MPRecordEncoder*)mp_encoderForPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels: (int)ch samples:(Float64)rate;

- (instancetype)initPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels: (int)ch samples:(Float64)rate;

- (void)mp_finishWithCompletionHandler:(void (^)(void))handler;

- (BOOL)mp_encodeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;
@end

NS_ASSUME_NONNULL_END
