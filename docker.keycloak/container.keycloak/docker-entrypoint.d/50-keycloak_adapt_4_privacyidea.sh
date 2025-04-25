#!/bin/sh
#
# ident "@(#)$Id: 50-keycloak_adapt_4_privacyidea.sh | Tue Nov 21 13:47:29 2023 +0100 | scgu0003 @ rz-co-02  $"
# $Author: scgu0003 @ rz-co-02 <scgu0003@h-ka.de> $
#
# Copyright 2023 (c) Guenther Schreiner <guenther.schreiner@smile.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
# Description:
#      Enhancing with PrivacyIDEA-Provider.
#
# Configuration:
#       @see Constants
#
###
### Constants
###
#
###
### Main
###
echo ">> Enhancing with PrivacyIDEA-Provider." >/dev/stderr
#
# For details, @see: https://www.privacyidea.org/versatile-2fa-single-sign-on-with-keycloak-and-privacyidea/
#
echo ">>> Copying PrivacyIDEA-Provider..." >/dev/stderr
cp /container/keycloak-config/PrivacyIDEA-Provider-v1.4.0.KC22.jar /opt/keycloak/providers/ >/dev/stderr
echo ">>> Reconfiguring Keycloak ..." >/dev/stderr
/opt/keycloak/bin/kc.sh build >/dev/stderr
#
echo ">> Done: Enhancing with PrivacyIDEA-Provider." >/dev/stderr
#
# Flag to run ONLY ONCE.
#
exit 0
#
# end-of-50-keycloak_adapt_4_privacyidea.sh
#
