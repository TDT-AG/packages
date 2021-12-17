cmake_minimum_required(VERSION 2.6)

PROJECT(dbus-example C)
ADD_DEFINITIONS(-Os -Wall --std=gnu99 -Wmissing-declarations)

SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")

FIND_PACKAGE(PkgConfig REQUIRED)
pkg_search_module(GLIB REQUIRED glib-2.0)
pkg_search_module(GIO REQUIRED gio-2.0)
pkg_search_module(GIOUNIX REQUIRED gio-unix-2.0)

include_directories(${GLIB_INCLUDE_DIRS})
link_directories(${GLIB_LIBRARY_DIRS})

include_directories(${GIO_INCLUDE_DIRS})
link_directories(${GIO_LIBRARY_DIRS})

include_directories(${GIOUNIX_INCLUDE_DIRS})
link_directories(${GIOUNIX_LIBRARY_DIRS})

add_executable(service-alarm main.c alarm.c)

add_definitions(${GLIB_CFLAGS_OTHER})
add_definitions(${GIO_CFLAGS_OTHER})
add_definitions(${GIOUNIX_CFLAGS_OTHER})
target_link_libraries(service-alarm ${GLIB_LIBRARIES})
target_link_libraries(service-alarm ${GIO_LIBRARIES})
target_link_libraries(service-alarm ${GIOUNIX_LIBRARIES})

INSTALL(TARGETS service-alarm RUNTIME DESTINATION /usr/sbin)
