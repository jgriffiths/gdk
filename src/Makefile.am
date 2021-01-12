noinst_LTLIBRARIES =

include_HEADERS =
include_HEADERS += $(top_srcdir)/include/gdk.h
include_HEADERS += $(top_srcdir)/include/wally_wrapper.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_address.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_bip32.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_bip38.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_bip39.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_core.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_crypto.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_elements.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_psbt.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_script.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_symmetric.h
include_HEADERS += $(top_srcdir)/src/libwally-core/include/wally_transaction.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = greenaddress.pc

lib_LTLIBRARIES = libgreenaddress.la

libgreenaddress_la_SOURCES = \
    amount.cpp \
    assertion.cpp \
    containers.cpp \
    exception.cpp \
    ffi_c.cpp \
    ga_auth_handlers.cpp \
    ga_cache.cpp \
    ga_rust.cpp \
    ga_session.cpp \
    ga_strings.cpp \
    ga_tor.cpp \
    ga_tx.cpp \
    ga_wally.cpp \
    http_client.cpp \
    network_parameters.cpp \
    session.cpp \
    signer.cpp \
    socks_client.cpp \
    transaction_utils.cpp \
    tx_list_cache.cpp \
    utils.cpp \
    xpub_hdkey.cpp

libgreenaddress_la_INCLUDES = \
    include/gdk.h \
    include/wally_wrapper.h

# FIXME: build-clang/include use a configure arg
libgreenaddress_la_CXXFLAGS = -I$(top_srcdir) -I$(top_srcdir)/src/autobahn-cpp -I$(top_srcdir)/src/msgpack-c/include -I$(top_srcdir)/src/websocketpp -I$(top_srcdir)/src/json/include -I$(top_srcdir)/src/GSL/include -I$(top_srcdir)/src/tor/src/feature/api -I../build-clang/include $(AM_CXXFLAGS)
libgreenaddress_la_LIBADD = $(noinst_LTLIBRARIES)

