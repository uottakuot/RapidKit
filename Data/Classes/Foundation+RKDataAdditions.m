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
#import <sys/xattr.h>
#import "Foundation+RKDataAdditions.h"

#define PERFORM_SELECTOR_WITHOUT_WARNING(object, selector, value) ((void (*)(id, SEL, id))[object methodForSelector:selector])(object, selector, value)

static NSString* const RKObjectTagPropertyKey = @"RKObjectTagPropertyKey";

@implementation NSObject (RKDataFoundationNSObjectAdditions)

+ (NSString*)setterSelectorStringForPropertyName:(NSString*)name {
    objc_property_t property = class_getProperty([self class], [name cStringUsingEncoding:NSUTF8StringEncoding]);
    char* setterCString = property_copyAttributeValue(property, "S");
    return [NSString stringWithUTF8String:setterCString];
}

+ (Class)subclassWithPrefix:(NSString*)prefix suffix:(NSString*)suffix created:(BOOL*)created {
    if (created != NULL) {
        *created = NO;
    }
    
    NSString* originalName = NSStringFromClass(self);
    BOOL hasPrefix = [prefix length] > 0 ? [originalName hasPrefix:prefix] : YES;
    BOOL hasSuffix = [suffix length] > 0 ? [originalName hasSuffix:suffix] : YES;
    
    if (hasPrefix && hasSuffix) {
        return self;
    }
    
    if (prefix == nil) {
        prefix = @"";
    }
    
    if (suffix == nil) {
        suffix = @"";
    }
    
    NSString* newClassName = [NSString stringWithFormat:@"%@%@%@", prefix, originalName, suffix];
    const char* newClassNameCString = [newClassName cStringUsingEncoding:NSASCIIStringEncoding];
    Class class = objc_getClass(newClassNameCString);
    if (class == Nil) {
        class = objc_allocateClassPair(self, newClassNameCString, 0);
        objc_registerClassPair(class);
        
        if (created != NULL) {
            *created = YES;
        }
    }
    
    return class;
}

+ (NSArray*)propertyNamesIncludingSuperclasses:(BOOL)includingSuperclasses {
    NSMutableArray* properties = [NSMutableArray array];
    
    Class currentClass = self;
    while (currentClass != [NSObject class]) {
        unsigned int count = 0;
        objc_property_t* propertyList = class_copyPropertyList(currentClass, &count);
        for (NSInteger i = 0; i < count; i++) {
            NSString* propertyName = [NSString stringWithUTF8String:property_getName(propertyList[i])];
            [properties addObject:propertyName];
        }
        free(propertyList);
    }
    
    return properties;
}

+ (void)enumeratePropertiesHierarchically:(BOOL)hierarchically withBlock:(void (^)(RKPropertyInfo info))block {
    Class currentClass = self;
    while (currentClass != [NSObject class]) {
        unsigned int count = 0;
        objc_property_t* propertyList = class_copyPropertyList(currentClass, &count);
        for (NSInteger i = 0; i < count; i++) {
            NSString* propertyName = [NSString stringWithUTF8String:property_getName(propertyList[i])];
            RKPropertyInfo info;
            info.ownerClass = currentClass;
            info.name = propertyName;
            info.typeClass = Nil;
            info.isReadonly = NO;
            info.getter = NULL;
            info.setter = NULL;
            info.encodedTypeCharacter = 0;
            
            NSString* attributesString = [NSString stringWithUTF8String:property_getAttributes(propertyList[i])];
            NSArray* attributes = [attributesString componentsSeparatedByString:@","];
            
            for (NSString* attribute in attributes) {
                unichar firstCharacter = [attribute characterAtIndex:0];
                switch (firstCharacter) {
                    case 'T': {
                        NSString* typeName = [attribute substringFromIndex:1];
                        if ([typeName characterAtIndex:0] == '@')
                            info.typeClass = NSClassFromString([typeName substringWithRange:NSMakeRange(2, [typeName length] - 3)]);
                        else if ([typeName length] == 1)
                            info.encodedTypeCharacter = [typeName characterAtIndex:0];
                        break;
                    }
                    
                    case 'R':
                        info.isReadonly = YES;
                        break;
                    
                    case 'G':
                        info.getter = NSSelectorFromString([attribute substringFromIndex:1]);
                        break;
                    
                    case 'S':
                        info.setter = NSSelectorFromString([attribute substringFromIndex:1]);
                        break;
                    
                    default:
                        break;
                }
            }
            
            if (info.getter == NULL) {
                info.getter = NSSelectorFromString(info.name);
            }
            
            if (info.setter == NULL) {
                NSString* capitalizedName = [info.name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[info.name substringToIndex:1] uppercaseString]];
                NSString* setterString = [NSString stringWithFormat:@"set%@:", capitalizedName];
                info.setter = NSSelectorFromString(setterString);
            }
            
            if (block != nil) {
                block(info);
            }
        }
        
        free(propertyList);
        
        currentClass = [currentClass superclass];
    }
}

+ (void)replaceInstanceMethod:(IMP)imp forSelector:(SEL)selector {
    Method method = class_getInstanceMethod([self class], selector);
    const char* encoding = method_getTypeEncoding(method);
    
    if (!class_addMethod([self class], selector, imp, encoding)) {
        method_setImplementation(method, imp);
    }
}

+ (IMP)instanceMethodOfSuperclassForSelector:(SEL)selector {
    Method method = class_getInstanceMethod([self superclass], selector);
    if (method != NULL) {
        IMP superImp = method_getImplementation(method);
        IMP selfImp = [self instanceMethodForSelector:selector];
        if (superImp != selfImp) {
            return superImp;
        }
    }
    
    return NULL;
}

+ (id)objectAssociatedWithKey:(id)key {
    return objc_getAssociatedObject(self, (__bridge void*)key);
}

+ (void)setObject:(id)object associatedWithKey:(id)key retain:(BOOL)retain {
    objc_setAssociatedObject(self, (__bridge void*)key, object, (retain ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_ASSIGN));
}

- (id)objectAssociatedWithKey:(id)key {
    return objc_getAssociatedObject(self, (__bridge void*)key);
}

- (void)setObject:(id)object associatedWithKey:(id)key retain:(BOOL)retain {
    objc_setAssociatedObject(self, (__bridge void*)key, object, (retain ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_ASSIGN));
}

- (void)setClass:(Class)class {
    object_setClass(self, class);
}

- (void)repeatPerformSelector:(SEL)selector afterDelay:(NSTimeInterval)delay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
    [self performSelector:selector withObject:nil afterDelay:delay];
}

@end

@implementation NSMutableDictionary (RKDataFoundationNSMutableDictionaryAdditions)

- (void)setOrRemoveObject:(id)object forKey:(id<NSCopying>)key {
    if (key == nil) {
        return;
    }
    
    if (object != nil) {
        [self setObject:object forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

@end
