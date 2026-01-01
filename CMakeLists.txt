cmake_minimum_required(VERSION 3.10)
project(milk-streamtelemetry-cca C)

find_package(PkgConfig REQUIRED)

pkg_check_modules(CFITSIO REQUIRED cfitsio)
pkg_check_modules(OPENBLAS REQUIRED openblas)
pkg_check_modules(LAPACKE REQUIRED lapacke)

add_executable(milk-streamtelemetry-cca main.c)

target_include_directories(milk-streamtelemetry-cca PRIVATE
    ${CFITSIO_INCLUDE_DIRS}
    ${OPENBLAS_INCLUDE_DIRS}
    ${LAPACKE_INCLUDE_DIRS}
)

target_link_libraries(milk-streamtelemetry-cca PRIVATE
    ${CFITSIO_LIBRARIES}
    ${OPENBLAS_LIBRARIES}
    ${LAPACKE_LIBRARIES}
    m
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -Wall")
