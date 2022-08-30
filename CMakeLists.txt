cmake_minimum_required(VERSION 3.19 FATAL_ERROR)

# Qt Custom config
set(QC_PROJECT_NAME "QtQuickExample")

# Project declare
project( ${QC_PROJECT_NAME} )
message(STATUS "[${PROJECT_NAME}] Project ${PROJECT_NAME}")

# Check Arch
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(QC_CPU_ARCH x64)
else()
    set(QC_CPU_ARCH x86)
endif()
message(STATUS "[${PROJECT_NAME}] CPU_ARCH:${QC_CPU_ARCH}")

# CMake set
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# default RelWithDebInfo
## Debug, Release, RelWithDebInfo(Release with debug info), MinSizeRel(minisize release)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()
message(STATUS "[${PROJECT_NAME}] BUILD_TYPE:${CMAKE_BUILD_TYPE}")

# Compiler set
message(STATUS "[${PROJECT_NAME}] C++ compiler ID is: ${CMAKE_CXX_COMPILER_ID}")
if (MSVC)
    # FFmpeg cannot be compiled natively by MSVC version < 12.0 (2013)
    if(MSVC_VERSION LESS 1800)
        message(FATAL_ERROR "[${PROJECT_NAME}] ERROR: MSVC version is older than 12.0 (2013).")
    endif()

    message(STATUS "[${PROJECT_NAME}] Set Warnings as error")
    # warning level 3 and all warnings as errors
    add_compile_options(/W3 /WX /wd4566)

    # avoid warning C4819
    add_compile_options(-source-charset:utf-8)
    #add_compile_options(/utf-8)

    # ensure we use minimal "windows.h" lib without the crazy min max macros
    add_compile_definitions(NOMINMAX WIN32_LEAN_AND_MEAN)

    # disable SAFESEH - avoid "LNK2026: module unsafe"(Qt5.15&&vs2019)     
    add_link_options(/SAFESEH:NO)
endif()

if (NOT MSVC)
    message(STATUS "[${PROJECT_NAME}] Set warnings as error")
    # lots of warnings and all warnings as errors
    add_compile_options(-Wall -Wextra -pedantic -Werror)

    # disable some warning
    add_compile_options(-Wno-nested-anon-types -Wno-c++17-extensions -Wno-overloaded-virtual)
endif()

# Qt Setting
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_PREFIX_PATH "/home/ian/Apps/Qt_5_12/5.12.12/gcc_64")
find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Multimedia Widgets Quick REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Multimedia Widgets Quick REQUIRED)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(QT NAMES Qt6 Qt5 COMPONENTS X11Extras REQUIRED)
    find_package(Qt${QT_VERSION_MAJOR} COMPONENTS X11Extras REQUIRED)
endif()

message(STATUS "[${PROJECT_NAME}] Qt version is: ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}")

## Source
### cmoudle
set (QC_CMOUDLE_SOURCES
    cmoudle.h
    cmoudle.cpp
)

### qrc
set(QC_QRC_SOURCES
    qml.qrc
)
### qml
# set(QC_QML_FILES
#     CusButton.qml
#     main.qml
# )
# qt5_add_qml_module(${PROJECT_NAME} QC_QML_FILES)

### main
set(QC_MAIN_SOURCES
    main.cpp
    ${QC_QRC_SOURCES}
)

# All sources
set(QC_PROJECT_SOURCES
    ${QC_IAMGE_SOURCES}
    ${QC_CMOUDLE_SOURCES}
    ${QC_MAIN_SOURCES}
)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(QC_RUNTIME_TYPE MACOSX_BUNDLE)
endif()
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(QC_RUNTIME_TYPE WIN32)
endif()

# find_package( OpenCV REQUIRED )
# include_directories( ${OpenCV_INCLUDE_DIRS} )
if (ANDROID)
    add_library(${PROJECT_NAME} ${QC_RUNTIME_TYPE} ${QC_PROJECT_SOURCES})
else()
    add_executable(${PROJECT_NAME} ${QC_RUNTIME_TYPE} ${QC_PROJECT_SOURCES})
endif()


# target_link_libraries( DisplayImage.out ${OpenCV_LIBS} )


# output dir
## https://cmake.org/cmake/help/latest/prop_gbl/GENERATOR_IS_MULTI_CONFIG.html
get_property(QC_IS_MUTIL_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
message(STATUS "multi config:" QC_IS_MUTIL_CONFIG)

## $<0:> 使用生成器表达式为每个config设置RUNTIME_OUTPUT_DIRECTORY，这样multi config就不会自动追加CMAKE_B    UILD_TYPE子目录了
## 1. multi config介绍 https://cmake.org/cmake/help/latest/prop_gbl/GENERATOR_IS_MULTI_CONFIG.html
## 2. multi config在不用表达式生成器时自动追加子目录说明 https://cmake.org/cmake/help/latest/prop_tgt/RU    NTIME_OUTPUT_DIRECTORY.html
## 3. 使用表达式生成器禁止multi config自动追加子目录解决方案 https://stackoverflow.com/questions/7747857    /in-cmake-how-do-i-work-around-the-debug-and-release-directories-visual-studio-2
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../output/${QC_CPU_ARCH}/${CMAKE_BUILD_TYPE}/    $<0:>"
)


# plantform deps 移动一些图片之类的静态文件,但是依然不能在应用里显示出来....伤心

# windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    get_target_property(QSC_BIN_OUTPUT_PATH ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY)
    set(QSC_DEPLOY_PATH ${QSC_BIN_OUTPUT_PATH})

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/images/rocket.png" "${QSC_BIN_OUTPUT_PATH}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/images/sky.jpg" "${QSC_BIN_OUTPUT_PATH}"
    )
endif()

# MacOS
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    # copy bundle file
    get_target_property(MACOS_BUNDLE_PATH ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY)
    set(MACOS_BUNDLE_PATH ${MACOS_BUNDLE_PATH}/${PROJECT_NAME}.app/Contents)

    set(QSC_DEPLOY_PATH ${MACOS_BUNDLE_PATH})

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        # config file copy to Contents/MacOS/config
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/images/rocket.png" "${MACOS_BUNDLE_PATH}/MacOS"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/images/sky.jpg" "${MACOS_BUNDLE_PATH}/MacOS"
    )

    # Step 2. ues MACOSX_PACKAGE_LOCATION copy icns to Resources
    set_source_files_properties(
        ${CMAKE_CURRENT_SOURCE_DIR}/res/${PROJECT_NAME}.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )

    # use MACOSX_BUNDLE_INFO_PLIST custom plist, not use MACOSX_BUNDLE_BUNDLE_NAME etc..
    # set(INFO_PLIST_TEMPLATE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/XXXXX/Info_Mac.plist.in")
    # set(INFO_PLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/XXXXX/Info_Mac.plist")
    file(READ "${INFO_PLIST_TEMPLATE_FILE}" plist_contents)
    string(REPLACE "\${BUNDLE_VERSION}" "${PROJECT_VERSION}" plist_contents ${plist_contents})
    file(WRITE ${INFO_PLIST_FILE} ${plist_contents})
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${INFO_PLIST_FILE}"
        # "" disable code sign
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
    )

    # mac framework
    target_link_libraries(${PROJECT_NAME} PRIVATE "-framework AppKit")
endif()

# Linux
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    get_target_property(QSC_BIN_OUTPUT_PATH ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY)
    set(QSC_DEPLOY_PATH ${QSC_BIN_OUTPUT_PATH})
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/images/rocket.png" "${QSC_BIN_OUTPUT_PATH}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/images/sky.jpg" "${QSC_BIN_OUTPUT_PATH}"
    )
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        # qx11
        Qt${QT_VERSION_MAJOR}::X11Extras
        # xcb https://doc.qt.io/qt-5/linux-requirements.html
        xcb
        # pthread
        Threads::Threads
    )
    # linux set app icon: https://blog.csdn.net/MrNoboday/article/details/82870853
endif()


# target_link_libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Multimedia
)
