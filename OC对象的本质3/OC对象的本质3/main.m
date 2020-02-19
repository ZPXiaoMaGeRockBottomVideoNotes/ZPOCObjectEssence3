//
//  main.m
//  OC对象的本质3
//
//  Created by 赵鹏 on 2019/5/1.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>

//NSObject类的底层实现
struct NSObject_IMPL {
    Class isa;
};

//自定义类
@interface Person : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation Person

@end

/**
 ·自定义Person类的底层实现：
 ·理论上这个结构体应该占用8+4+4+4  = 20个字节的内存空间，但是从内存对齐的角度分析，结构体所占用的内存大小必须是其内部的最大成员变量的大小的整数倍，所以这个结构体应该占3*8 = 24个字节的内存空间；
 ·下面的main函数中的class_getInstanceSize函数的打印结果是24，malloc_size函数的打印结果是32，意味着实际上系统给这个结构体分配了32个字节，但实际上它只用了24个字节。
 */
struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS;  //大小为8个字节
    int _age;  //int类型为4个字节
    int _height;  //4个字节
    int _no;  //4个字节
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /**
         ·sizeof函数的打印结果是24；
         ·sizeof是一个运算符，不是函数，在程序编译的时候就被替换成了常数了，有点像宏定义。class_getInstanceSize是一个函数，在程序运行的时候会调用这个函数。
         */
        NSLog(@"%zd", sizeof(struct Person_IMPL));
        
        /**
         ·class_getInstanceSize函数会根据这个类的本质（结构体）内的成员变量来计算至少需要多少内存空间，算过之后，这个结构体理论上应该占用8+4+4+4  = 20个字节的内存空间。但是从内存对齐的角度分析，结构体所占用的内存大小必须是其内部的最大成员变量的大小的整数倍，所以这个结构体应该占3*8 = 24个字节的内存空间，所以打印出来的结果是24；
         ·malloc_size函数表示创建一个类的实例对象，系统实际上需要分配了多少的内存空间；
         ·本来创建Person类的实例对象只需要24个字节的内存空间，但是系统为了更快更方便地利用这块内存，一般会给对象分配16字节的倍数的内存空间的大小，所以这里系统会给Person类的对象分配32个字节的内存空间，所以打印结果是32。
         */
        Person *person = [[Person alloc] init];
        NSLog(@"%zd, %zd", class_getInstanceSize([Person class]), malloc_size((__bridge const void *)(person)));
    }
    
    return 0;
}
