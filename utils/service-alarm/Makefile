#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=service-alarm
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Florain Eckert <fe@dev.tdt.de>
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/service-alarm
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=service-alaram glib2 example
  DEPENDS:=+glib2
endef

define Package/service-alarm/description
  That should be all you need to write a simple server and client
  with glib2 C API.
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	cd $(PKG_BUILD_DIR) && \
		$(STAGING_DIR_HOSTPKG)/bin/gdbus-codegen \
			--interface-prefix es.aleksander \
			--generate-c-code alarm \
			es.aleksander.Alarm.xml
endef

define Package/service-alarm/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/service-alarm \
		$(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/dbus-1/system.d
	$(INSTALL_BIN) ./files/etc/dbus-1/system.d/es.aleksander.Alarm.conf \
		$(1)/etc/dbus-1/system.d

endef

$(eval $(call BuildPackage,service-alarm))
