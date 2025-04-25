#!/bin/sh
#
# ident "@(#)$Id: 30-keycloak_config_import.sh | Sat Nov 18 22:55:00 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
# $Author: UnknownUser @ MacBook-Air-GS-6.local <UnknownUser@h-ka.de> $
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
#      Importing of an existing Keycloak configuration.
#
# Configuration:
#       @see Constants
#
###
### Constants
###
#
# Determine the configuration storage area
#
SRCDIR=/container/rw/config/
#
###
### Main
###
# 
# TBD
# 
exit 1
echo ">> Importing of Keycloak configuration." >/dev/stderr
#
# A workaround
#
. /container/docker-entrypoint.d/__-Docker_secret_helper
#
# Start the Keycloak with special options:
#
/opt/keycloak/bin/kc.sh import  --dir ${SRCDIR} >/dev/stderr
#
echo ">> Done: Importing of Keycloak configuration." >/dev/stderr
#
# Flag to run this script every reboot
#
exit 1
#
# end-of-30-keycloak_config_import.sh
#
