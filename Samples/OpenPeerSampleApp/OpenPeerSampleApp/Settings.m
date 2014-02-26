/*
 
 Copyright (c) 2013, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */

#import "Settings.h"
#import "AppConsts.h"
#import "OpenPeer.h"
#import "Logger.h"
#import "SBJsonParser.h"

@interface Settings ()

- (NSString*) getArchiveStringForModule:(Modules) module;
@end

@implementation Settings



/**
 Retrieves singleton object of the Settings.
 @return Singleton object of the Settings.
 */
+ (id) sharedSettings
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

- (id)initSingleton
{
    self = [super init];
    if (self)
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveMediaAEC])
            self.isMediaAECOn = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveMediaAEC] boolValue];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveMediaAGC])
            self.isMediaAGCOn = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveMediaAGC] boolValue];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveMediaNS])
            self.isMediaNSOn = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveMediaNS] boolValue];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveRemoteSessionActivationMode])
            self.isRemoteSessionActivationModeOn = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveRemoteSessionActivationMode] boolValue];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveFaceDetectionMode])
            self.isFaceDetectionModeOn = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveFaceDetectionMode] boolValue];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveRedialMode])
            self.isRedialModeOn = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveRedialMode] boolValue];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:archiveStdOutLogger])
            self.enabledStdLogger = [[[NSUserDefaults standardUserDefaults] objectForKey:archiveStdOutLogger] boolValue];
        
        self.appModulesLoggerLevel =[[[NSUserDefaults standardUserDefaults] objectForKey:archiveModulesLogLevels] mutableCopy];
        
        if (!self.appModulesLoggerLevel)
            self.appModulesLoggerLevel = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) enableMediaAEC:(BOOL) enable
{
    self.isMediaAECOn = enable;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isMediaAECOn] forKey:archiveMediaAEC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) enableMediaAGC:(BOOL) enable
{
    self.isMediaAGCOn = enable;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isMediaAGCOn] forKey:archiveMediaAGC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) enableMediaNS:(BOOL) enable
{
    self.isMediaNSOn = enable;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isMediaNSOn] forKey:archiveMediaNS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) enableRemoteSessionActivationMode:(BOOL) enable
{
    self.isRemoteSessionActivationModeOn = enable;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isRemoteSessionActivationModeOn] forKey:archiveRemoteSessionActivationMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) enableFaceDetectionMode:(BOOL) enable
{
    self.isFaceDetectionModeOn = enable;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isFaceDetectionModeOn] forKey:archiveFaceDetectionMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) enableRedialMode:(BOOL) enable
{
    self.isRedialModeOn = enable;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isRedialModeOn] forKey:archiveRedialMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)getArchiveKeyForLoggerType:(LoggerTypes)type
{
    NSString *key= nil;
    
    switch (type)
    {
        case LOGGER_STD_OUT:
            key = archiveStdOutLogger;
            break;
            
        case LOGGER_TELNET:
            key = archiveTelnetLogger;
            break;
            
        case LOGGER_OUTGOING_TELNET:
            key = archiveOutgoingTelnetLogger;
            break;
            
        default:
            break;
    }
    return key;
}

- (void) enable:(BOOL) enable logger:(LoggerTypes) type
{
    NSString* key = [self getArchiveKeyForLoggerType:type];
    
    if ([key length] > 0)
    {
        key = [key stringByAppendingString:archiveEnabled];
        [[NSUserDefaults standardUserDefaults] setBool:enable forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL) isLoggerEnabled:(LoggerTypes) type
{
    BOOL ret = NO;
    NSString* key = [self getArchiveKeyForLoggerType:type];
    
    if ([key length] > 0)
    {
        key = [key stringByAppendingString:archiveEnabled];
        ret = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }
    
    return ret;
}

- (void) setServerOrPort:(NSString*) server logger:(LoggerTypes) type
{
    NSString* key = [self getArchiveKeyForLoggerType:type];
    
    if ([key length] > 0)
    {
        key = [key stringByAppendingString:archiveServer];
        [[NSUserDefaults standardUserDefaults] setObject:server forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString*) getServerPortForLogger:(LoggerTypes) type
{
    NSString* ret = nil;
    NSString* key = [self getArchiveKeyForLoggerType:type];
    
    if ([key length] > 0)
    {
        key = [key stringByAppendingString:archiveServer];
        ret = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    
    return ret;
}

- (void) setColorizedOutput:(BOOL) colorized logger:(LoggerTypes) type
{
    NSString* key = [self getArchiveKeyForLoggerType:type];
    
    if ([key length] > 0)
    {
        key = [key stringByAppendingString:archiveColorized];
        [[NSUserDefaults standardUserDefaults] setBool:colorized forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL) isColorizedOutputForLogger:(LoggerTypes) type
{
    BOOL ret = NO;
    NSString* key = [self getArchiveKeyForLoggerType:type];
    
    if ([key length] > 0)
    {
        key = [key stringByAppendingString:archiveColorized];
        ret = [[NSUserDefaults standardUserDefaults] boolForKey:key];;
    }
    
    return ret;
}

- (HOPLoggerLevels) getLoggerLevelForAppModule:(Modules) module
{
    HOPLoggerLevels ret = HOPLoggerLevelNone;
    
    NSString* archiveString = [self getArchiveStringForModule:module];
    if ([archiveString length] > 0)
        ret = [self getLoggerLevelForAppModuleKey:archiveString];
    
    return ret;
}

- (HOPLoggerLevels) getLoggerLevelForAppModuleKey:(NSString*) moduleKey
{
    HOPLoggerLevels ret = HOPLoggerLevelNone;
    
    NSNumber* retNumber = [self.appModulesLoggerLevel objectForKey:moduleKey];
    if (retNumber)
        ret = (HOPLoggerLevels)[retNumber intValue];
    
    return ret;
}

- (void) setLoggerLevel:(HOPLoggerLevels) level forAppModule:(Modules) module
{
    NSString* archiveString = [self getArchiveStringForModule:module];
    [self.appModulesLoggerLevel setObject:[NSNumber numberWithInt:level] forKey:archiveString];
    [self saveModuleLogLevels];
}

- (void) saveModuleLogLevels
{
    [[NSUserDefaults standardUserDefaults] setObject:self.appModulesLoggerLevel forKey:archiveModulesLogLevels];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) getStringForModule:(Modules) module
{
    NSString* ret = nil;
    
    switch (module)
    {
        case MODULE_APPLICATION:
            ret = @"Application";
            break;
            
        case MODEULE_SDK:
            ret = @"SDK (iOS)";
            break;

        case MODULE_MEDIA:
            ret = @"SDK (media)";
            break;

        case MODULE_WEBRTC:
            ret = @"SDK (webRTC)";
            break;

        case MODULE_CORE:
            ret = @"SDK (core)";
            break;

        case MODULE_STACK_MESSAGE:
            ret = @"SDK (messages)";
            break;

        case MODULE_STACK:
            ret = @"SDK (stack)";
            break;

        case MODULE_SERVICES:
            ret = @"SDK (services)";
            break;

        case MODULE_SERVICES_WIRE:
            ret = @"SDK (services packets)";
            break;

        case MODULE_SERVICES_ICE:
            ret = @"SDK (STUN/ICE)";
            break;

      case MODULE_SERVICES_TURN:
            ret = @"SDK (TURN)";
            break;

        case MODULE_SERVICES_RUDP:
            ret = @"SDK (RUDP)";
            break;

        case MODULE_SERVICES_HTTP:
            ret = @"SDK (HTTP)";
            break;

        case MODULE_SERVICES_MLS:
            ret = @"SDK (MLS)";
            break;

        case MODULE_SERVICES_TCP:
            ret = @"SDK (TCP Messaging)";
            break;

        case MODULE_SERVICES_TRANSPORT:
            ret = @"SDK (Transport Stream)";
            break;

        case MODULE_ZSLIB:
            ret = @"SDK (zsLib)";
            break;
            
        case MODULE_JAVASCRIPT:
            ret = @"JavaScript";
            break;
            default:
            break;
    }
    
    return ret;
}

- (NSString*) getArchiveStringForModule:(Modules) module
{
    NSString* ret = nil;
    
    switch (module)
    {
        case MODULE_APPLICATION:
            ret = moduleApplication;
            break;
            
        case MODEULE_SDK:
            ret = moduleSDK;
            break;
            
        case MODULE_MEDIA:
            ret = moduleMedia;
            break;
            
        case MODULE_WEBRTC:
            ret = moduleWebRTC;
            break;
            
        case MODULE_CORE:
            ret = moduleCore;
            break;
            
        case MODULE_STACK_MESSAGE:
            ret = moduleStackMessage;
            break;
            
        case MODULE_STACK:
            ret = moduleStack;
            break;
            
        case MODULE_SERVICES:
            ret = moduleServices;
            break;
            
        case MODULE_SERVICES_WIRE:
            ret = moduleServicesWire;
            break;

        case MODULE_SERVICES_ICE:
            ret = moduleServicesIce;
            break;

        case MODULE_SERVICES_TURN:
          ret = moduleServicesTurn;
          break;

        case MODULE_SERVICES_RUDP:
          ret = moduleServicesRudp;
          break;

        case MODULE_SERVICES_HTTP:
            ret = moduleServicesHttp;
            break;

        case MODULE_SERVICES_MLS:
            ret = moduleServicesMls;
            break;

        case MODULE_SERVICES_TCP:
            ret = moduleServicesTcp;
            break;

        case MODULE_SERVICES_TRANSPORT:
            ret = moduleServicesTransport;
            break;

        case MODULE_ZSLIB:
            ret = moduleZsLib;
            break;
            
        case MODULE_JAVASCRIPT:
            ret = moduleJavaScript;
            break;
            
            default:
            break;
    }
    return ret;
}

- (NSString*) getStringForLogLevel:(HOPLoggerLevels) level
{
    switch (level)
    {
        case HOPLoggerLevelNone:
            return @"NONE";
            break;
            
        case HOPLoggerLevelBasic:
            return @"BASIC";
            break;
            
        case HOPLoggerLevelDetail:
            return @"DETAIL";
            break;
            
        case HOPLoggerLevelDebug:
            return @"DEBUG";
            break;
            
        case HOPLoggerLevelTrace:
            return @"TRACE";
            break;

        case HOPLoggerLevelInsane:
            return @"INSANE";
            break;

        default:
            break;
    }
    return nil;
}

- (void) saveDefaultsLoggerSettings
{
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_APPLICATION];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_SERVICES];
    [self setLoggerLevel:HOPLoggerLevelDebug forAppModule:MODULE_SERVICES_WIRE];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_SERVICES_ICE];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_SERVICES_TURN];
    [self setLoggerLevel:HOPLoggerLevelDebug forAppModule:MODULE_SERVICES_RUDP];
    [self setLoggerLevel:HOPLoggerLevelDebug forAppModule:MODULE_SERVICES_HTTP];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_SERVICES_MLS];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_SERVICES_TCP];
    [self setLoggerLevel:HOPLoggerLevelDebug forAppModule:MODULE_SERVICES_TRANSPORT];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_CORE];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_STACK_MESSAGE];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_STACK];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_ZSLIB];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODEULE_SDK];
    [self setLoggerLevel:HOPLoggerLevelDetail forAppModule:MODULE_WEBRTC];
    [self setLoggerLevel:HOPLoggerLevelDetail forAppModule:MODULE_MEDIA];
    [self setLoggerLevel:HOPLoggerLevelTrace forAppModule:MODULE_JAVASCRIPT];
    
    [self setColorizedOutput:YES logger:LOGGER_STD_OUT];
    [self setColorizedOutput:YES logger:LOGGER_TELNET];
    [self setColorizedOutput:YES logger:LOGGER_OUTGOING_TELNET];
    
    [self enable:YES logger:LOGGER_STD_OUT];
    [self enable:YES logger:LOGGER_TELNET];
    [self enable:YES logger:LOGGER_OUTGOING_TELNET];
}

- (NSString*) getOuterFrameURL
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"outerFrameURL"];
}

- (NSString*) getNamespaceGrantServiceURL
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"namespaceGrantServiceURL"];
}

- (NSString*) getIdentityProviderDomain
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"identityProviderDomain"];
}

- (NSString*) getIdentityFederateBaseURI
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"identityFederateBaseURI"];
}

- (NSString*) getLockBoxServiceDomain
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"lockBoxServiceDomain"];
}

- (NSString*) getDefaultOutgoingTelnetServer
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"archiveOutgoingTelnetLoggerServer"];
}
- (BOOL) isAppDataSet
{
    BOOL ret = YES;
    
    ret &= [[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppId] length] != 0;
    ret &= [[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppIdSharedSecret] length] != 0;
    ret &= [[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppName] length] != 0;
    ret &= [[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppURL] length] != 0;
    ret &= [[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppImageURL] length] != 0;
    
#ifdef APNS_ENABLED
    ret &= [[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppImageURL] length] != 0;
#endif
    return ret;
}

- (BOOL) isLoginSettingsSet
{
    BOOL ret = YES;
    
    ret &= [[self getOuterFrameURL] length] != 0;
    ret &= [[self getIdentityFederateBaseURI] length] != 0;
    ret &= [[self getIdentityProviderDomain] length] != 0;
    ret &= [[self getNamespaceGrantServiceURL] length] != 0;
    ret &= [[self getLockBoxServiceDomain] length] != 0;
    ret &= [[self getDefaultOutgoingTelnetServer] length] != 0;
    
    return ret;
}

- (BOOL) isAppSettingsSetForPath:(NSString*) path
{
    BOOL ret = YES;
    NSDictionary* customerSpecificDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if ([customerSpecificDict count] > 0)
    {
        NSString* appID = [customerSpecificDict objectForKey:archiveAppId];
        NSString* appSecret = [customerSpecificDict objectForKey:archiveAppIdSharedSecret];
        NSString* appName = [customerSpecificDict objectForKey:archiveAppName];
        
        if ([appID length] == 0 || [appSecret length] == 0 || [appName length] == 0)
            ret = NO;
    }
    
    return ret;
}

- (NSArray*) getMissingAppSettings
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppId] length] == 0)
        [ret addObject: archiveAppId];
    

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:archiveAppIdSharedSecret] length] == 0)
        [ret addObject: archiveAppIdSharedSecret];
    return ret;
}

- (NSDictionary*) dictionaryWithRemovedAllInvalidEntriesForPath:(NSString*) path
{
    NSMutableDictionary* plistDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if ([plistDictionary count] > 0)
    {
        for (NSString* key in [plistDictionary allKeys])
        {
           id value = [plistDictionary objectForKey:key];
            if ([value isKindOfClass:[NSString class]])
            {
                if ([((NSString*)value) rangeOfString:@"<--"].location != NSNotFound)
                {
                    [plistDictionary removeObjectForKey:key];
                }
            }
            
        }
    }
    
    return plistDictionary;
}
@end
