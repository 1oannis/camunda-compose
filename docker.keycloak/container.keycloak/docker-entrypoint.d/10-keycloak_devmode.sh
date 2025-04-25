#!/bin/sh
#
# ident "@(#)$Id: 10-keycloak_devmode.sh | Sat Nov 18 22:55:00 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
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
#      Waiting a while for the initial spinning up of the database.
#
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
#
# Welcome to this container
#
echo ">> Optionally starting Keycloak in development mode." >/dev/stderr
#
# Start the Keycloak:
#  determined by cmd:	docker inspect -f '{{.Config.Entrypoint}}' IMAGEID
#
# 
# Keycloak script variable determines to start in development mode.
#
if [ -z "$KEYCLOAK_DEVMODE" ]; then
   #
   # Nothing to do so far
   #
   true
else
   #
   # Start
   #
   echo ">>> Starting Keycloak in development mode." >/dev/stderr
   #
   # A workaround
   #
   . /container/docker-entrypoint.d/__-Docker_secret_helper
   #
   # Start Keycloak
   #
   /opt/keycloak/bin/kc.sh start-dev	>/dev/stderr
   echo ">>> Keycloak terminated - should not occur." >/dev/stderr
fi
#
#
#
echo ">> Done: Optionally starting Keycloak in development mode." >/dev/stderr
#
# Flag to run this script every reboot
#
exit 1
#
# end-of-10-keycloak_devmode.sh
#

