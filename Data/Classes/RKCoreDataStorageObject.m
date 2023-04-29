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

#import "RKCoreDataStorageObject.h"
#import "RKCoreDataStorageObjectArray.h"
#import "RKCoreDataStorage.h"

@interface RKCoreDataStorageObject ()

@property (nonatomic, strong) NSMutableDictionary* arraysByName;

@end

@implementation RKCoreDataStorageObject

RK_SYNTH(entityInternal)
RK_SYNTH(entityStorageInternal)
RK_SYNTH(arraysByName)

- (RKEntity*)createEntityInternal {
    RKEntity* object = _entityInternal;
    if (object == nil) {
        Class class = [[(RKCoreDataStorage*)_entityStorageInternal classesByEntityName] objectForKey:[[self entity] name]];
        object = [[class alloc] initInternal];
        [object setDataSourceInternal:self];
        _entityInternal = object;
    }
    
    return object;
}

#pragma mark - Private

- (NSMutableDictionary*)arraysByName {
    if (_arraysByName == nil) {
        _arraysByName = [NSMutableDictionary dictionary];
    }
    
    return _arraysByName;
}

- (id)valueForKeyInternal:(NSString*)key {
    id value = [self valueForKey:key];
    
    if ([value isKindOfClass:[NSMutableSet class]]) {
        RKCoreDataStorageObjectArray* array = [[self arraysByName] objectForKey:key];
        if (array == nil) {
            array = [[RKCoreDataStorageObjectArray alloc] initWithManagedObject:self collectionKeyPath:key];
            [[self arraysByName] setObject:array forKey:key];
        }
        value = array;
    } else if ([value isKindOfClass:[RKCoreDataStorageObject class]]) {
        RKEntity* object = [value entityInternal];
        if (object == nil) {
//            Class class = [[(RKCoreDataStorage*)[self entityStorageInternal] classesByEntityName] objectForKey:[[value entity] name]];
//            object = [[class alloc] initInternal];
//            [object setDataSourceInternal:value];
//            [value setEntityInternal:object];
            [value setEntityStorageInternal:[self entityStorageInternal]];
            object = [value createEntityInternal];
        }
        value = object;
    }
    
    return value;
}

- (void)setValueInternal:(id)value forKey:(NSString*)key {
    if ([value isKindOfClass:[RKEntity class]]) {
        [[self entityStorageInternal] registerObject:value];
        [self setValue:[value dataSourceInternal] forKey:key];
    } else {
        [self setValue:value forKey:key];
    }
}

#pragma mark - RKEntityDataSource

- (void)addObject:(RKEntity*)object toCollectionNamed:(NSString*)name {
    [[self entityStorageInternal] registerObject:object];
    [[self mutableSetValueForKey:name] addObject:[object dataSourceInternal]];
}

- (void)removeObject:(RKEntity*)object fromCollectionNamed:(NSString*)name {
    if ([object dataSourceInternal] != nil) {
        [[self mutableSetValueForKey:name] removeObject:[object dataSourceInternal]];
    }
}

@end
