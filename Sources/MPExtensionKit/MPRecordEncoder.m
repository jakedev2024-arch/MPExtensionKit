
#import "MPRecordEncoder.h"

@interface MPRecordEncoder ()<AVAssetWriterDelegate>

@property (nonatomic, strong) AVAssetWriter *mp_writer;//媒体写入对象
@property (nonatomic, strong) AVAssetWriterInput *mp_videoInput;//视频写入
@property (nonatomic, strong) AVAssetWriterInput *mp_audioInput;//音频写入
@property (nonatomic, strong) NSString *mp_path;//写入路径

@end

@implementation MPRecordEncoder

- (void)dealloc {
    _mp_writer = nil;
    _mp_videoInput = nil;
    _mp_audioInput = nil;
    _mp_path = nil;
}


+ (MPRecordEncoder*)mp_encoderForPath:(NSString*) path Height:(NSInteger) cy width:(NSInteger) cx channels: (int) ch samples:(Float64) rate {
    MPRecordEncoder* enc = [MPRecordEncoder alloc];
    return [enc initPath:path Height:cy width:cx channels:ch samples:rate];
}


- (instancetype)initPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels:(int)ch samples:(Float64) rate {
    self = [super init];
    if (self) {
        self.mp_path = path;
        [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
        NSURL* url = [NSURL fileURLWithPath:self.mp_path];
        _mp_writer = [[AVAssetWriter alloc]initWithURL:url fileType:AVFileTypeMPEG4 error:nil];
        _mp_writer.shouldOptimizeForNetworkUse = YES;
        [self initVideoInputHeight:cy width:cx];
        if (rate != 0 && ch != 0) {
            [self initAudioInputChannels:ch samples:rate];
        }
    }
    return self;
}

- (void)initVideoInputHeight:(NSInteger)cy width:(NSInteger)cx {
    

    // 设置一些我们自己指定的视频参数
  
    NSDictionary *compressionDict = @{
        AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
        AVVideoMaxKeyFrameIntervalKey: @(30), // 增加关键帧间隔以提高压缩效率
    };


    NSDictionary *settings = @{
        AVVideoCodecKey: AVVideoCodecTypeH264,          // 视频编码器类型
        AVVideoWidthKey: @(cx),                          // 视频宽度
        AVVideoHeightKey: @(cy),                         // 视频高度
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,//缩放显示模式
        AVVideoCompressionPropertiesKey: compressionDict
        
    };
    _mp_videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _mp_videoInput.expectsMediaDataInRealTime = YES;
//    _videoInput.transform = CGAffineTransformMakeRotation(M_PI/2);
    [_mp_writer addInput:_mp_videoInput];
}

- (void)initAudioInputChannels:(int)ch samples:(Float64)rate {

    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [ NSNumber numberWithInt: ch], AVNumberOfChannelsKey,
                              [ NSNumber numberWithFloat: rate], AVSampleRateKey,
                              [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                              nil];

    _mp_audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];

    _mp_audioInput.expectsMediaDataInRealTime = YES;
    [_mp_writer addInput:_mp_audioInput];
    
}

- (void)mp_finishWithCompletionHandler:(void (^)(void))handler {
    [_mp_writer finishWritingWithCompletionHandler: handler];
    

}

-(void)start:(CMSampleBufferRef) sampleBuffer {
    
}

- (BOOL)mp_encodeFrame:(CMSampleBufferRef) sampleBuffer isVideo:(BOOL)isVideo {

    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        if (_mp_writer.status == AVAssetWriterStatusUnknown && isVideo) {
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_mp_writer startWriting];
            [_mp_writer startSessionAtSourceTime:startTime];
        }
        if (_mp_writer.status == AVAssetWriterStatusFailed) {
            NSLog(@"writer error %@", _mp_writer.error.localizedDescription);
            return NO;
        }
        if (isVideo) {
            if (_mp_videoInput.readyForMoreMediaData == YES) {
                [_mp_videoInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }else {
       
            if (_mp_audioInput.readyForMoreMediaData) {
                [_mp_audioInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
    }
    return NO;
}




@end


