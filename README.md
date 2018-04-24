## OVERVIEW
该工程是Swift版本的官方Camera使用案例，并简单封装。

## Build Library 
```Shell
tensorflow/contrib/makefile/build_all_ios.sh -a arm64 armv7s armv7 // 编译真机的版本
```

## Link Binary With Libraries
在`Build Phases` -> `Link Binary With Libraries`中添加如下依赖:
* `Accelerate.framework`
* `tensorflow/tensorflow/contrib/makefile/gen/lib/ios_ARM64/libtensorflow-core.a`
* `tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib/libprotobuf.a`
* `tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib/libprotobuf-lite.a`
* `tensorflow/tensorflow/contrib/makefile/downloads/nsync/builds/lipo.ios.c++11/nsync.a`

## Library Search Paths
在`Build Settings` -> `Library Search Paths`中添加如下路径：
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/lib/ios_ARM64`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/downloads/nsync/builds/lipo.ios.c++11`

## Header Search Paths
在`Build Settings` -> `Header Search Paths`中添加如下路径：
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/downloads/protobuf/src`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/downloads/nsync/public`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/downloads/eigen`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/downloads`

## User Header Search Paths
在`Build Settings` -> `User Header Search Paths`中添加如下路径：
* `$(PROJECT_DIR)`
* `$(PROJECT_DIR)/tensorflow`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/proto/`

## Other Linker Flags
在`Build Settings` -> `Other Linker Flags`中添加如下路径：
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib/libprotobuf-lite.a`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib/libprotobuf.a`
* `-force_load`
* `$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/lib/ios_ARM64/libtensorflow-core.a`

## 其他
在`Build Settings`里，设置如下：
* Enable Bitcode： No
* Warnings / Documentation Comments: No
* Warnings / Deprecated Functions: No

# TIPS

## 在头文件 include时出现 xxxx.pb.h not found
device_attributes.pb_text.h: No such file or directory 
请确保`$(PROJECT_DIR)/tensorflow/tensorflow/contrib/makefile/gen/proto/`已加入`Header Search Path`

## 在头文件 include时出现 xxxx.h not found
请确保`tensorflow/`与`.xcodeproj`目录层级关系正确

## 运行时出现 No session factory registered for the given session options
请确保`Other Linker Flags`里的路径正确引入，如果有`-all_load`则改为'`ObjC'

# Bazel安装
## 使用Homebrew
首先安装JDK8 + 、Homebrew
```shell
brew install bazel
```


# Model引用
在移动端使用Tensorflow需要两个文件：`xxx.pb`和`xxx.txt`。pb文件是Model，文本文件是识别结果的键。
拿到Model后直接引用时如果出现Model加载失败的错误。则是Model格式问题。
1.是否将Variables于Model合并。
2.是否转换成了移动端可用的Model。

对于第一点。要AI组提供新的Model。
第二点 则在`tensorflow/`下(安装过bazel)
```shell
bazel run tensorflow/tools/graph_transforms:transform_graph --
--in_graph=tensorflow_inception_graph.pb
--out_graph=optimized_inception_graph.pb --inputs='Mul' --outputs='final_result'
```
将model转换成移动端可用的格式。时间长长久久...


# 识别
在进行识别过程中，需要传递以下几个参数
```c++
private static final int INPUT_WIDTH = 299;
private static final int INPUT_HEIGHT = 299;
private static final int IMAGE_MEAN = 128;
private static final float IMAGE_STD = 128;
private static final String INPUT_NAME = "Mul";
private static final String OUTPUT_NAME = "final_result";

private static final String MODEL_FILE = "retrained_graph_optimized.pb";
private static final String LABEL_FILE =
"label.txt";
```

接下来就可以正确的引用啦
