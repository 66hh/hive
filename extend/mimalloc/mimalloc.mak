#工程名字
PROJECT_NAME = mimalloc

#目标名字
TARGET_NAME = mimalloc

#系统环境
UNAME_S = $(shell uname -s)

#伪目标
.PHONY: clean all target pre_build post_build
all : pre_build target post_build

#CFLAG
MYCFLAGS =

#需要定义的FLAG
MYCFLAGS += -Wsign-compare
MYCFLAGS += -Wno-sign-compare
MYCFLAGS += -Wno-unused-variable
MYCFLAGS += -Wno-unused-parameter
MYCFLAGS += -Wno-unknown-pragmas
MYCFLAGS += -Wno-unused-but-set-parameter
MYCFLAGS += -Wno-unused-function
MYCFLAGS += -Wno-unused-result

#c标准库版本
#gnu99/gnu11/gnu17
STDC = -std=gnu99

#c++标准库版本
#c++11/c++14/c++17/c++20
STDCPP = -std=c++17

#需要的include目录
MYCFLAGS += -Imimalloc/include

#需要定义的选项
MYCFLAGS += -DMI_SHARED_LIB
MYCFLAGS += -DMI_SHARED_LIB_EXPORT
MYCFLAGS += -DMI_MALLOC_OVERRIDE
MYCFLAGS += -DNDEBUG

#LDFLAGS
LDFLAGS =


#源文件路径
SRC_DIR = mimalloc/src

#需要排除的源文件,目录基于$(SRC_DIR)
EXCLUDE =
EXCLUDE += $(SRC_DIR)/static.c
EXCLUDE += $(SRC_DIR)/page-queue.c
EXCLUDE += $(SRC_DIR)/alloc-override.c

#需要连接的库文件
LIBS =
#自定义库
#系统库
LIBS += -lm -ldl -lstdc++ -lpthread

#定义基础的编译选项
ifndef CC
CC = gcc
endif
ifndef CX
CX = c++
endif
CFLAGS = -g -O2 -Wall -Wno-deprecated -Wextra $(STDC) $(MYCFLAGS)
CXXFLAGS = -g -O2 -Wall -Wno-deprecated -Wextra $(STDCPP) $(MYCFLAGS)

#项目目录
ifndef SOLUTION_DIR
SOLUTION_DIR=./
endif

#临时文件目录
INT_DIR = $(SOLUTION_DIR)temp/$(PROJECT_NAME)

#目标文件前缀，定义则.so和.a加lib前缀，否则不加
PROJECT_PREFIX = lib

#目标定义
MYCFLAGS += -fPIC
TARGET_DIR = $(SOLUTION_DIR)bin
TARGET_DYNAMIC =  $(TARGET_DIR)/$(PROJECT_PREFIX)$(TARGET_NAME).so
#soname
ifeq ($(UNAME_S), Linux)
LDFLAGS += -Wl,-soname,$(PROJECT_PREFIX)$(TARGET_NAME).so
endif
#install_name
ifeq ($(UNAME_S), Darwin)
LDFLAGS += -Wl,-install_name,$(PROJECT_PREFIX)$(TARGET_NAME).so
endif

#link添加.so目录
LDFLAGS += -L$(SOLUTION_DIR)bin
LDFLAGS += -L$(SOLUTION_DIR)library

#自动生成目标
OBJS =
#子目录
OBJS += $(patsubst $(SRC_DIR)/prim/%.c, $(INT_DIR)/prim/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/prim/*.c)))
OBJS += $(patsubst $(SRC_DIR)/prim/%.m, $(INT_DIR)/prim/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/prim/*.m)))
OBJS += $(patsubst $(SRC_DIR)/prim/%.cc, $(INT_DIR)/prim/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/prim/*.cc)))
OBJS += $(patsubst $(SRC_DIR)/prim/%.cpp, $(INT_DIR)/prim/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/prim/*.cpp)))
#根目录
OBJS += $(patsubst $(SRC_DIR)/%.c, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.c)))
OBJS += $(patsubst $(SRC_DIR)/%.m, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.m)))
OBJS += $(patsubst $(SRC_DIR)/%.cc, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.cc)))
OBJS += $(patsubst $(SRC_DIR)/%.cpp, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.cpp)))

# 编译所有源文件
$(INT_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.m
	$(CC) $(CFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.cc
	$(CX) $(CXXFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CX) $(CXXFLAGS) -c $< -o $@

$(TARGET_DYNAMIC) : $(OBJS)
	$(CC) -o $@ -shared $(OBJS) $(LDFLAGS) $(LIBS)

#target伪目标
target : $(TARGET_DYNAMIC)

#clean伪目标
clean :
	rm -rf $(INT_DIR)

#预编译
pre_build:
	mkdir -p $(INT_DIR)
	mkdir -p $(TARGET_DIR)
	mkdir -p $(INT_DIR)/prim

#后编译
post_build:
