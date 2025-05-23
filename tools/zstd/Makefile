include $(TOPDIR)/rules.mk

PKG_NAME:=zstd
PKG_VERSION:=1.5.7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/facebook/zstd/releases/download/v$(PKG_VERSION)
PKG_HASH:=eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:facebook:zstandard

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

HOSTCC:= $(HOSTCC_NOCACHE)

HOST_CFLAGS += $(HOST_FPIC)

HOST_MAKE_FLAGS += \
	BACKTRACE=0 \
	HAVE_THREAD=1 \
	HAVE_ZLIB=0 \
	HAVE_LZMA=0 \
	HAVE_LZ4=0 \
	PREFIX=$(HOST_BUILD_PREFIX)

define Host/Compile
	$(call Host/Compile/Default,lib-mt)
	$(call Host/Compile/Default,zstd)
endef

define Host/Install
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR)/lib install-static install-includes PREFIX=$(HOST_BUILD_PREFIX)
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR)/lib install-pc MT=1 PREFIX=$(HOST_BUILD_PREFIX)
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR)/programs install PREFIX=$(HOST_BUILD_PREFIX)
endef

define Host/Uninstall
	-$(call Host/Compile/Default,uninstall)
endef

$(eval $(call HostBuild))
