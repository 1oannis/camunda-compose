#!/bin/sh
#
# ident "@(#)$Id: 20-keycloak_config_export.sh | Sat Nov 18 22:55:00 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
# $Author: UnknownUser @ MacBook-Air-GS-6.local <UnknownUser@h-ka.de> $
#
# Copyright 2022 (c) Guenther Schreiner <guenther.schreiner@smile.de>
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
#      Exporting the existinf Keycloak configuration.
#  
# Configuration:
#       @see Constants
#  
###
### Constants
###
#
# Determine current date as part of the configuration storage area
#
DATE=$(date +%Y%m%d%H)
#
# Determine output directory as configuration storage area
#
DSTDIR=/container/rw/config_export_${DATE}
#
###
### Main
###
# 
# Welcome to this container
#
echo ">> Exporting of Keycloak configuration." >/dev/stderr
#
# Create configuration storage area
#
if [ -d "${DSTDIR}" ]; then
   #
   # Inform ths user
   #
   echo ">>> Doing nothing as output directory "${DSTDIR}" does already exist." >/dev/stderr
else
   #
   # Create the directory
   #
   echo ">>> Exporting into output directory "${DSTDIR}" ..." >/dev/stderr
   mkdir -p ${DSTDIR} >/dev/stderr
   #
   # A workaround
   #
   . /container/docker-entrypoint.d/__-Docker_secret_helper
   #
   # Start the Keycloak with special options:
   #
   /opt/keycloak/bin/kc.sh export  --dir ${DSTDIR}	>/dev/stderr
fi
#
echo ">> Done: Exporting of Keycloak configuration." >/dev/stderr
#
# Flag to run this script every reboot
#
exit 1
#
# end-of-20-keycloak_config_export.sh
#
