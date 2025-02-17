# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "wget2"
version = v"2.0.0"

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://ftp.gnu.org/gnu/wget/wget2-$(version).tar.gz", "4fe2fba0abb653ecc1cc180bea7f04212c17e8fe05c85aaac8baeac4cd241544")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/wget2*

./configure \
--prefix=${prefix} \
--build=${MACHTYPE} \
--host=${target} \
--enable-shared=yes \
--enable-static=no \
--without-libpsl \
--without-libhsts \
--without-libnghttp2 \
--without-bzip2 \
--without-gpgme  \
--without-lzma \
--without-brotlidec \
--without-lzip \
--without-libidn2 \
--without-libidn \
--without-libpcre2 \
--without-libpcre \
--without-libmicrohttpd \
--without-plugin-support \
--disable-doc \
--disable-manylibs

make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    ExecutableProduct("wget2", :wget2),
    #ExecutableProduct("wget2_noinstall", :wget2_noinstall),
    LibraryProduct("libwget", :libwget)
]

# Dependencies that must be installed before this package can be built
#Nettle and OpenSSL needed for mingw builds
dependencies = [
    Dependency(PackageSpec(name="GnuTLS_jll", uuid="0951126a-58fd-58f1-b5b3-b08c7c4a876d"))
    Dependency("Gettext_jll"; compat="=0.21.0")
    Dependency("Nettle_jll"; compat="~3.7.2")
    Dependency("OpenSSL_jll"; compat="1.1.10")
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
