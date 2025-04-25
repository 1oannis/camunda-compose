#!/bin/sh
#
# ident "@(#)$Id: 40-keycloak_adapt_quarkus.sh | Sat Nov 18 22:55:00 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
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
#      Adapting quarkus recovery mode.
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
echo ">> Adapting quarkus recovery mode." >/dev/stderr
#
# For details, @see: https://keycloak.discourse.group/t/solved-keycloak-20-0-2-transaction-recovery-warning/19142
#
echo quarkus.transaction-manager.enable-recovery=true > /opt/keycloak/conf/quarkus.properties
#
echo ">> Done: Adapting quarkus recovery mode." >/dev/stderr
#
# Flag to run this script every reboot
#
exit 1
#
# end-of-40-keycloak_adapt_quarkus.sh
#
