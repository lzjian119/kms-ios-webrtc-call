// KMSEventData.m
// Copyright (c) 2015 Dmitry Lizin (sdkdimon@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "KMSEventData.h"
#import "NSDictionary+Merge.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "MTLJSONAdapterWithoutNil.h"

@implementation KMSEventData


+(Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary{
    NSString *typeString = JSONDictionary[@"type"];
    KMSEventType type = (KMSEventType)[[self kmsEventTypesMap][typeString] integerValue];
    
    switch (type) {
        case KMSEventTypeOnICECandidate:
            return [KMSEventDataICECandidate class];
        case KMSEventTypeMediaElementDisconnected:
        case KMSEventTypeMediaElementConnected:
            return [KMSEventDataElementConnection class];
        default:
            break;
    }
    
    return self;
}

+(NSDictionary *)kmsEventTypesMap{
    
    return @{@"OnIceGatheringDone" :@(KMSEventTypeOnICEGatheringDone),
             @"OnIceCandidate" : @(KMSEventTypeOnICECandidate),
             @"ElementConnected" : @(KMSEventTypeMediaElementConnected),
             @"ElementDisconnected" : @(KMSEventTypeMediaElementDisconnected),
             @"MediaSessionStarted" : @(KMSEventTypeMediaSessionStarted),
             @"MediaSessionTerminated" : @(KMSEventTypeMediaSessionTerminated),
             @"ConnectionStateChanged" : @(KMSEventTypeConnectionStateChanged)};
}

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"type" : @"type"};
}


+(NSValueTransformer *)typeJSONTransformer{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:[self kmsEventTypesMap]];
}


@end

@implementation KMSEventDataICECandidate

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return [[super JSONKeyPathsByPropertyKey] dictionaryByMergingDictionary:  @{@"candidate" : @"candidate"}];
}

+(NSValueTransformer *)candidateJSONTransformer{
    return [MTLJSONAdapterWithoutNil dictionaryTransformerWithModelClass:[KMSICECandidate class]];
}

@end


@implementation KMSEventDataElementConnection

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if(self == nil) return nil;
    
    _elementConnection  = [[KMSElementConnection alloc] init];
    [_elementConnection setSource:_source];
    [_elementConnection setSink:_sink];
    [_elementConnection setMediaType:_mediaType];
    
    return self;
    
    
}

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return [[super JSONKeyPathsByPropertyKey] dictionaryByMergingDictionary:@{
                                                                                @"source" : @"source",
                                                                                @"sink" : @"sink",
                                                                                @"mediaType" : @"mediaType"
                                                                                }];
}

+(NSValueTransformer *)mediaTypeJSONTransformer{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{[NSNull null] : @(KMSMediaTypeNone),
                                                                           @"AUDIO" : @(KMSMediaTypeAudio),
                                                                           @"VIDEO" : @(KMSMediaTypeVideo),
                                                                           @"DATA" : @(KMSMediaTypeData)}];
}


@end


