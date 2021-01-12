AC_PREREQ([2.60])
AC_INIT([libgreenaddress],[0.8.1])
AC_CONFIG_AUX_DIR([tools/build-aux])
AC_CONFIG_MACRO_DIR([tools/build-aux/m4])
AC_CONFIG_SRCDIR([src/ga_wally.hpp])
AC_CONFIG_HEADERS([src/config.h])
AC_CANONICAL_HOST
AH_TOP([#ifndef GDK_CONFIG_H
#define GDK_CONFIG_H])
AH_BOTTOM([#endif /*GDK_CONFIG_H*/])

LDPATH_VAR=LD_LIBRARY_PATH
case $host_os in
*darwin*)
    is_osx="yes"
    LDPATH_VAR=DYLD_LIBRARY_PATH
    ;;
esac
AM_CONDITIONAL([IS_OSX], [test "x$is_osx" == "xyes"])
AC_SUBST([LDPATH_VAR])

AM_INIT_AUTOMAKE([foreign subdir-objects])
saved_cflags="$CFLAGS"
LT_INIT([disable-static])
CFLAGS="$saved_cflags"

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_PROG_CC
AC_PROG_CXX

# Prefer the compilers native ar/ranlib if available
# We have to manually loop to test these as autoconf inexplicably does
# not provide an AC_PATH_TOOLS macro for this purpose.
candidate_ars="ar"
candidate_ranlibs="ranlib"
case $CC in
*gcc*)
    candidate_ars="gcc-ar ar"
    candidate_ranlibs="gcc-ranlib ranlib"
    ;;
*clang*)
    ver=$($CC --version | head -n 1 | cut -d' '  -f3 | cut -d'.' -f1)
    candidate_ars="llvm-ar-$ver llvm-ar ar"
    candidate_ranlibs="llvm-ranlib-$ver llvm-ranlib ranlib"
    ;;
esac

if test "x$is_osx" == "xyes"; then
    candidate_ars="libtool $candidate_ars"
    CCDIR=`dirname $CC`
    if test x"$CCDIR" != x"."; then
        if test -x $CCDIR/libtool; then
            # Use libtool from the same directory as our clang
            AR=$CCDIR/libtool
            candidate_ars=""
        fi
    fi
fi

if test -n "$candidate_ars"; then
    for candidate in $candidate_ars; do
        AC_PATH_TOOL(AR, $candidate)
        if test "x$HAVE_AR" == "xyes"; then
            break
        fi
    done
fi
case $AR in
*libtool)
    ARFLAGS="-static -o"
    AR_FLAGS="-static -o"
    AC_SUBST([ARFLAGS])
    AC_SUBST([AR_FLAGS])
    ;;
esac

for candidate in $candidate_ranlibs; do
    AC_PATH_TOOL(RANLIB, $candidate)
    if test "x$HAVE_RANLIB" == "xyes"; then
        break
    fi
done

AC_SUBST([AR])
AC_SUBST([RANLIB])

GNU_SED=sed
AC_CHECK_PROG(HAVE_GSED,gsed,yes,no)
if test "x$HAVE_GSED" == "xyes"; then
  GNU_SED=gsed
else
    if test "x$is_osx" == "xyes"; then
        AC_MSG_ERROR([gsed must be available to build this library])
    fi
fi
AC_SUBST([GNU_SED])

#
# C facilities
#
AC_ARG_ENABLE(debug,
    AS_HELP_STRING([--enable-debug],[enable debugging (default: no)]),
    [debug=$enableval], [debug=no])
AC_ARG_ENABLE(coverage,
    AS_HELP_STRING([--enable-coverage],[enable code coverage (default: no)]),
    [coverage=$enableval], [coverage=no])
AC_ARG_ENABLE(tests,
    AS_HELP_STRING([--enable-tests],[enable code tests (default: yes)]),
    [tests=$enableval], [tests=yes])
AM_CONDITIONAL([RUN_TESTS], [test "x$tests" == "xyes"])

AC_C_BIGENDIAN()
AC_C_INLINE
AC_TYPE_SIZE_T
AC_TYPE_UINT64_T
AC_TYPE_UINT32_T
AC_TYPE_UINT16_T
AC_TYPE_UINT8_T

AM_CFLAGS=
AX_CHECK_COMPILE_FLAG([-O0], [NOOPT_CFLAGS="-O0"])

if test "x$debug" == "xyes"; then
    # Make debugging easier, leave assertions in
    AM_CFLAGS="$AM_CFLAGS $NOOPT_CFLAGS"
    AX_CHECK_COMPILE_FLAG([-ggdb], [AM_CFLAGS="$AM_CFLAGS -ggdb"])
    AX_CHECK_LINK_FLAG([-O0], [LDFLAGS="$LDFLAGS -O0"])
    AX_CHECK_LINK_FLAG([-ggdb], [LDFLAGS="$LDFLAGS -ggdb"])
    if test "x$coverage" == "xyes"; then
        AX_CHECK_COMPILE_FLAG([-fprofile-arcs -ftest-coverage], [AM_CFLAGS="$AM_CFLAGS -fprofile-arcs -ftest-coverage"])
        AX_CHECK_LINK_FLAG([-lgcov], [LDFLAGS="$LDFLAGS -lgcov"])
    fi
else
    # Optimise and harden if we can
    AX_CHECK_COMPILE_FLAG([-O2], [AM_CFLAGS="-O2 $AM_CFLAGS"])
    AC_CHECK_DEFINE([_FORTIFY_SOURCE], [], [
      AX_CHECK_COMPILE_FLAG([-D_FORTIFY_SOURCE=2],
        [CPPFLAGS="$CPPFLAGS -D_FORTIFY_SOURCE=2"])
    ])
    AX_CHECK_COMPILE_FLAG([-fstack-protector-strong], [AM_CFLAGS="$AM_CFLAGS -fstack-protector-strong"])
    AX_CHECK_COMPILE_FLAG([-DNDEBUG=1], [AM_CFLAGS="$AM_CFLAGS -DNDEBUG=1"])
    AX_CHECK_LINK_FLAG([-O2], [LDFLAGS="-O2 $LDFLAGS"])
    AX_CHECK_LINK_FLAG([-Wl,-z,relro], [LDFLAGS="$LDFLAGS -Wl,-z,relro"])
fi

# -flax-vector-conversions is needed for our arm assembly
AX_CHECK_COMPILE_FLAG([-flax-vector-conversions], [AM_CFLAGS="$AM_CFLAGS -flax-vector-conversions"])
AX_CHECK_COMPILE_FLAG([-fno-strict-aliasing], [NOALIAS_CFLAGS="-fno-strict-aliasing"])
AX_CHECK_COMPILE_FLAG([-fno-builtin], [NOBUILTIN_CFLAGS="-fno-builtin"])

AX_CHECK_COMPILE_FLAG([-Wformat-nonliteral], [AM_CFLAGS="-Wformat-nonliteral $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wformat-security], [AM_CFLAGS="-Wformat-security $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wformat], [AM_CFLAGS="-Wformat $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wstrict-prototypes], [AM_CFLAGS="-Wstrict-prototypes $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wshadow], [AM_CFLAGS="-Wshadow $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wnested-externs], [AM_CFLAGS="-Wnested-externs $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wcast-align], [AM_CFLAGS="-Wcast-align $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wpedantic], [AM_CFLAGS="-Wpedantic $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wextra], [AM_CFLAGS="-Wextra $AM_CFLAGS"])
AX_CHECK_COMPILE_FLAG([-Wall], [AM_CFLAGS="-Wall $AM_CFLAGS"])

# Needed for Ubuntu 20.04LTS when compiling as a library
AX_CHECK_COMPILE_FLAG([-D_DEFAULT_SOURCE=1], [AM_CFLAGS="-D_DEFAULT_SOURCE=1 $AM_CFLAGS"])

# Disable some unhelpful errors from those enabled above
AX_CHECK_COMPILE_FLAG([-Wno-unused-function], [AM_CFLAGS="$AM_CFLAGS -Wno-unused-function"])
AX_CHECK_COMPILE_FLAG([-Wno-long-long], [AM_CFLAGS="$AM_CFLAGS -Wno-long-long"])
AX_CHECK_COMPILE_FLAG([-Wno-overlength-strings], [AM_CFLAGS="$AM_CFLAGS -Wno-overlength-strings"])
AX_CHECK_COMPILE_FLAG([-Wno-variadic-macros], [AM_CFLAGS="$AM_CFLAGS -Wno-variadic-macros"])

if [[ "$CC" == *"clang"* ]]; then
    AX_CHECK_COMPILE_FLAG([-Wno-gnu-statement-expression], [AM_CFLAGS="$AM_CFLAGS -Wno-gnu-statement-expression"])
    AX_CHECK_COMPILE_FLAG([-Wno-zero-length-array], [AM_CFLAGS="$AM_CFLAGS -Wno-zero-length-array"])
    AX_CHECK_COMPILE_FLAG([-Wno-language-extension-token], [AM_CFLAGS="$AM_CFLAGS -Wno-language-extension-token"])
    AX_CHECK_COMPILE_FLAG([-Wno-unknown-attributes], [AM_CFLAGS="$AM_CFLAGS -Wno-unknown-attributes"])
fi
AC_SUBST([NOOPT_CFLAGS])
AC_SUBST([NOALIAS_CFLAGS])
AC_SUBST([NOBUILTIN_CFLAGS])

# Under OSX the compiler accepts this flag but the linker then fails.
if test "x$is_osx" != "xyes"; then
    AX_CHECK_COMPILE_FLAG([-Wl,--whole-archive], [whole_archive=yes])
fi

# SWIG versions vary in generated code quality; skip warnings
SWIG_WARN_CFLAGS="-fno-strict-aliasing"
AX_CHECK_COMPILE_FLAG([-Wno-shadow], [SWIG_WARN_CFLAGS="$SWIG_WARN_CFLAGS -Wno-shadow"])
AX_CHECK_COMPILE_FLAG([-Wno-self-assign], [SWIG_WARN_CFLAGS="$SWIG_WARN_CFLAGS -Wno-self-assign"])
AX_CHECK_COMPILE_FLAG([-Wno-missing-field-initializers], [SWIG_WARN_CFLAGS="$SWIG_WARN_CFLAGS -Wno-missing-field-initializers"])
AC_SUBST([SWIG_WARN_CFLAGS])

AX_CHECK_COMPILE_FLAG([-fvisibility=hidden], [AM_CFLAGS="$AM_CFLAGS -fvisibility=hidden"])

# Assume we have no unaligned access if cross-compiling
AC_RUN_IFELSE([AC_LANG_SOURCE([[int main(void){static int a[2];return *((int*)(((char*)a)+1)) != 0;}]])],
              have_unaligned=1, have_unaligned=0, have_unaligned=0)
AC_DEFINE_UNQUOTED([HAVE_UNALIGNED_ACCESS], [$have_unaligned], [Define if we have unaligned access])

if test "x$is_osx" != "xyes"; then
    # Assume we are using gcc (i.e. have this attribute) if cross-compiling
    AC_COMPILE_IFELSE([AC_LANG_SOURCE([extern int foo(int) __attribute__((weak)); int main(void){return 0;}])],
                      [AC_DEFINE([HAVE_ATTRIBUTE_WEAK], 1, [Define if we have __attribute__((weak))])])
fi

AX_PTHREAD([ac_have_pthread=yes], [ac_have_pthread=no])
AM_CONDITIONAL([USE_PTHREAD], [test "x$ac_have_pthread" == "xyes" -a "x$clear_tests" == "xyes"])
if test "x$ac_have_pthread" == "xyes"; then
    AC_DEFINE([HAVE_PTHREAD], 1, [Define if we have pthread support])
fi

AC_SUBST([AM_CFLAGS])
AM_CONDITIONAL([SHARED_BUILD_ENABLED], [test "x$enable_shared" == "xyes"])

GIT_TAG=`git rev-parse HEAD`
AC_SUBST([GIT_TAG])

AC_CONFIG_FILES([
 Makefile
 src/Makefile
 src/greenaddress.pc
 src/version.h
])

AC_OUTPUT
