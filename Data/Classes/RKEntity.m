// MIT License
//
// Copyright (c) Uottakuot Software
// https://github.com/uottakuot/RapidKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <objc/runtime.h>
#import "RKEntity.h"
#import "RKDataPrivate.h"

static NSString* const RKEntityActualSubclassPrefix = @"RKData_";
static NSString* const RKEntityActualSubclassPropertyName = @"RKEntityActualSubclassPropertyName";

static NSInteger getIntegerValue(RKEntity* self, SEL cmd) {
    NSInteger value = 0;
    
    if ([self isRegistered]) {
        NSString* key = [RKEntity propertyNameForSelector:cmd];
        value = [[[self dataSourceInternal] valueForKeyInternal:key] integerValue];
    } else {
        IMP prevImp = [[self superclass] instanceMethodForSelector:cmd];
        if (prevImp != NULL) {
            void* v = ((void*(*)(id, SEL))prevImp)(self, cmd);
            value = (NSInteger)v;
        }
    }
    
    return value;
}

static void setIntegerValue(RKEntity* self, SEL cmd, NSInteger value) {
    IMP prevImp = [[self superclass] instanceMethodForSelector:cmd];
    if (prevImp != NULL) {
        ((void*(*)(id, SEL, NSInteger))prevImp)(self, cmd, value);
    }
    
    if ([self isRegistered]) {
        NSString* key = [RKEntity propertyNameForSelector:cmd];
        double oldValue = [[[self dataSourceInternal] valueForKeyInternal:key] integerValue];
        if (oldValue != value) {
            [[self dataSourceInternal] setValueInternal:@(value) forKey:key];
            [[[self dataSourceInternal] entityStorageInternal] objectDidChange:self];
        }
    }
}

static double getFloatValue(RKEntity* self, SEL cmd) {
    double value = 0;
    
    if ([self isRegistered]) {
        NSString* key = [RKEntity propertyNameForSelector:cmd];
        value = [[[self dataSourceInternal] valueForKeyInternal:key] doubleValue];
    } else {
        IMP prevImp = [[self superclass] instanceMethodForSelector:cmd];
        if (prevImp != NULL) {
            void* v = ((void*(*)(id, SEL))prevImp)(self, cmd);
            value = *(double*)v;
        }
    }
    
    return value;
}

static void setFloatValue(RKEntity* self, SEL cmd, double value) {
    IMP prevImp = [[self superclass] instanceMethodForSelector:cmd];
    if (prevImp != NULL) {
        ((void*(*)(id, SEL, double))prevImp)(self, cmd, value);
    }
    
    if ([self isRegistered]) {
        NSString* key = [RKEntity propertyNameForSelector:cmd];
        double oldValue = [[[self dataSourceInternal] valueForKeyInternal:key] doubleValue];
        if (oldValue != value) {
            [[self dataSourceInternal] setValueInternal:@(value) forKey:key];
            [[[self dataSourceInternal] entityStorageInternal] objectDidChange:self];
        }
    }
}

static id getObjectValue(RKEntity* self, SEL cmd) {
    id value = nil;
    
    if ([self isRegistered]) {
        NSString* key = [RKEntity propertyNameForSelector:cmd];
        value = [[self dataSourceInternal] valueForKeyInternal:key];
    } else {
        IMP prevImp = [[self superclass] instanceMethodForSelector:cmd];
        if (prevImp != NULL) {
            value = ((id(*)(id, SEL))prevImp)(self, cmd);
        }
    }
    
    return value;
}

static void setObjectValue(RKEntity* self, SEL cmd, id value) {
    IMP prevImp = [[self superclass] instanceMethodForSelector:cmd];
    if (prevImp != NULL) {
        ((void*(*)(id, SEL, id))prevImp)(self, cmd, value);
    }
    
    if ([self isRegistered]) {
        NSString* key = [RKEntity propertyNameForSelector:cmd];
        id oldValue = [[self dataSourceInternal] valueForKeyInternal:key];
        if (oldValue == nil && value != nil || oldValue != nil && value == nil || oldValue != nil && ![oldValue isEqual:value]) {
            [[self dataSourceInternal] setValueInternal:value forKey:key];
            [[[self dataSourceInternal] entityStorageInternal] objectDidChange:self];
        }
    }
}

@implementation RKEntity

+ (void)registerRelationshipForClass:(Class)class1 propertyName:(NSString*)name1
                           withClass:(Class)class2 propertyName:(NSString*)name2
                     firstDeleteRule:(RKEntityDeleteRule)firstDeleteRule
                    secondDeleteRule:(RKEntityDeleteRule)secondDeleteRule
                            modifier:(RKEntityModifier)modifier {
    RKEntityRelationship* relationship = [[RKEntityRelationship alloc] init];
    [relationship setFirstClass:class1];
    [relationship setFirstPropertyName:name1];
    [relationship setSecondClass:class2];
    [relationship setSecondPropertyName:name2];
    [relationship setFirstDeleteRule:firstDeleteRule];
    [relationship setSecondDeleteRule:secondDeleteRule];
    [relationship setModifier:modifier];
    
    [[self relationships] addObject:relationship];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [self setChangeObservationEnabled:YES];
        object_setClass(self, [[self class] actualClass]);
    }
    
    return self;
}

- (BOOL)isPersistent {
    return [self dataSourceInternal] != nil;
}

- (RKEntityStorage*)entityStorage {
    return [[self dataSourceInternal] entityStorageInternal];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: 0x%lx>", [[self class] description], (long)self];
}

- (void)addObject:(RKEntity*)object toCollectionNamed:(NSString*)name {
    if (object == nil) {
        return;
    }
    
    if ([object isRegistered]) {
        [[[object dataSourceInternal] entityStorageInternal] registerObject:self];
    }
    
    if ([self isRegistered]) {
        [[self dataSourceInternal] addObject:object toCollectionNamed:name];
        [[self referencedObjects] addObject:object];
        [[[self dataSourceInternal] entityStorageInternal] objectDidChange:self];
        [[[self dataSourceInternal] entityStorageInternal] objectDidChange:object];
    } else {
        NSMutableArray* objects = [self valueForKey:name];
        if (objects == nil) {
            objects = [NSMutableArray array];
            [self setValue:objects forKey:name];
        }
        
        if (![objects containsObject:object]) {
            [objects addObject:object];
        }
    }
}

- (void)removeObject:(RKEntity*)object fromCollectionNamed:(NSString*)name {
    if (object == nil) {
        return;
    }
    
    if ([self isRegistered]) {
        [[self dataSourceInternal] removeObject:object fromCollectionNamed:name];
        [_referencedObjects removeObject:object];
        
        [[[self dataSourceInternal] entityStorageInternal] objectDidChange:self];
        [[[self dataSourceInternal] entityStorageInternal] objectDidChange:object];
    } else {
        NSMutableArray* objects = [self valueForKey:name];
        [objects removeObject:object];
    }
}

- (void)willRegister {
    //
}

- (void)didRegister {
    //
}

- (void)willUnregister {
    //
}

- (void)didUnregister {
    //
}

#pragma mark - Private

+ (Class)actualClass {
    // TODO: optimize
    NSString* className = NSStringFromClass(self);
    if ([className hasPrefix:RKEntityActualSubclassPrefix]) {
        return self;
    }
    
    Class class = [self objectAssociatedWithKey:RKEntityActualSubclassPropertyName];
    if (class == Nil) {
        [self prepareEntity];
    }
    
    return [self objectAssociatedWithKey:RKEntityActualSubclassPropertyName];
}

+ (void)prepareEntity {
    NSString* subclassName = [NSString stringWithFormat:@"%@%@", RKEntityActualSubclassPrefix, NSStringFromClass(self)];
    const char* subclassNameCString = [subclassName cStringUsingEncoding:NSASCIIStringEncoding];
    Class class = objc_getClass(subclassNameCString);
    
    if (class == Nil) {
        class = objc_allocateClassPair([self class], subclassNameCString, 0);
        objc_registerClassPair(class);
        
        [self enumeratePropertiesHierarchically:YES withBlock:^(RKPropertyInfo info) {
            if (info.ownerClass == [RKEntity class] || info.isReadonly)
                return;
            
            [[RKEntity propertyNamesBySelectors] setObject:info.name forKey:[NSValue valueWithPointer:info.getter]];
            [[RKEntity propertyNamesBySelectors] setObject:info.name forKey:[NSValue valueWithPointer:info.setter]];
            
            if (info.encodedTypeCharacter == 'f' || info.encodedTypeCharacter == 'd') {
                [class replaceInstanceMethod:(IMP)getFloatValue forSelector:info.getter];
                [class replaceInstanceMethod:(IMP)setFloatValue forSelector:info.setter];
            } else if (info.encodedTypeCharacter != 0) { // suppose it's of integer type
                [class replaceInstanceMethod:(IMP)getIntegerValue forSelector:info.getter];
                [class replaceInstanceMethod:(IMP)setIntegerValue forSelector:info.setter];
            } else if (info.typeClass != Nil) {
                [class replaceInstanceMethod:(IMP)getObjectValue forSelector:info.getter];
                [class replaceInstanceMethod:(IMP)setObjectValue forSelector:info.setter];
            }
        }];
        
        [self setObject:class associatedWithKey:RKEntityActualSubclassPropertyName retain:NO];
    }
}

+ (NSString*)description {
    NSString* className = NSStringFromClass(self);
    if ([className hasPrefix:RKEntityActualSubclassPrefix]) {
        return NSStringFromClass([self superclass]);
    }
    
    return NSStringFromClass(self);
}

+ (NSMutableArray*)relationships {
    static dispatch_once_t predicate;
    static NSMutableArray* relationships = nil;
    
    dispatch_once(&predicate, ^{
        relationships = [NSMutableArray array];
    });
    
    return relationships;
}

+ (RKEntityRelationship*)relationshipForClass:(Class)class propertyName:(NSString*)name
                             counterpartClass:(Class*)counterpartClass counterpartPropertyName:(NSString**)counterpartName {
    for (RKEntityRelationship* relationship in [self relationships]) {
        if ([relationship firstClass] == class && [[relationship firstPropertyName] isEqualToString:name]) {
            if (counterpartClass != NULL) {
                *counterpartClass = [relationship secondClass];
            }
            
            if (counterpartName != NULL) {
                *counterpartName = [relationship secondPropertyName];
            }
            
            return relationship;
        } else if ([relationship secondClass] == class && [[relationship secondPropertyName] isEqualToString:name]) {
            if (counterpartClass != NULL) {
                *counterpartClass = [relationship firstClass];
            }
            
            if (counterpartName != NULL) {
                *counterpartName = [relationship firstPropertyName];
            }
            
            return relationship;
        }
    }
    return nil;
}

+ (NSMutableDictionary*)propertyNamesBySelectors {
    static dispatch_once_t predicate;
    static NSMutableDictionary* properties = nil;
    
    dispatch_once(&predicate, ^{
        properties = [NSMutableDictionary dictionary];
    });
    
    return properties;
}

+ (NSString*)propertyNameForSelector:(SEL)selector {
    return [[self propertyNamesBySelectors] objectForKey:[NSValue valueWithPointer:selector]];
}

- (id)initInternal {
    self = [super init];
    if (self != nil) {
        [self setChangeObservationEnabled:YES];
        object_setClass(self, [[self class] actualClass]);
    }
    return self;
}

- (NSMutableArray*)referencedObjects {
    if (_referencedObjects == nil) {
        _referencedObjects = [NSMutableArray array];
    }
    
    return _referencedObjects;
}

- (BOOL)isRegistered {
    return _dataSourceInternal != nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self != nil) {
        // TODO:
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    // TODO:
}

@end
