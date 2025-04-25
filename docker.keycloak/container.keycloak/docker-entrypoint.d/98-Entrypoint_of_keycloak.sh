#!/bin/sh
#
# ident "@(#)$Id: 98-Entrypoint_of_keycloak.sh | Sat Nov 18 22:55:00 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
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
#      Starting Keycloak in production mode.
#
# Configuration:
#       @see Constants
#
###
### Constants
###
#
# Wait timeinterval in seconds
#
WAIT_SECS=10
# 
###
### Main
###
# 
# Say hello.
#
echo ">> Starting Keycloak." >/dev/stderr
#
# Start the Keycloak:
#  determined by cmd:	docker inspect -f '{{.Config.Entrypoint}}' IMAGEID
#
   #
   # A workaround
   #
   . /container/docker-entrypoint.d/__-Docker_secret_helper
   #
   # Execute the original Keycloak container entrypoint
   #
   /opt/keycloak/bin/kc.sh start >/dev/stderr
   #
   # Print a warning
   #
   echo "###################################################################" >/dev/stderr
   echo "##### WARNING: Keycloak terminated (this should NEVER occur). #####" >/dev/stderr
   echo "###################################################################" >/dev/stderr
   #
   # Stay clam and wait a while
   #
   sleep ${WAIT_SECS}
#
#
#
echo ">> Done: Starting Keycloak." >/dev/stderr
#
# Flag to run this script ONCE.
#
exit 0
#
# end-of-98-Entrypoint_of_keycloak.sh
#
