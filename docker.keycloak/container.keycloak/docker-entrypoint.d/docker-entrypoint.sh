#!/bin/bash
#
# ident "@(#)$Id: docker-entrypoint.sh | Sat Nov 18 14:46:21 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
# $Author: UnknownUser @ MacBook-Air-GS-6.local <UnknownUser@h-ka.de> $
#
# Copyright 2022-2023 (c) Guenther Schreiner <guenther.schreiner@smile.de>
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
#      Generic startup script for containers.
#
#	When a Docker container is run, it runs the ENTRYPOINT (only),
#	passing the CMD as command-line parameters, and when the ENTRYPOINT
#	completes the container exits. In the Dockerfile the ENTRYPOINT has
#	to be JSON-array syntax for it to be able to see the CMD arguments,
#	and the script itself needs to actually run the CMD, typically with
#	a line like exec "$@".
#
#	ENTRYPOINT ["/container/docker-entrypoint.d/docker-entrypoint.sh"]
#	CMD [ "runsvdir","-P", "/container/runit-config" ]
#
# Configuration:
#       @see Constants
#
###
### Main
###
#
# Welcome to this container
#
echo "################################################################################" >/dev/stderr
echo "##### Welcome to the container $(uname -n) #####################################" >/dev/stderr
echo "################################################################################" >/dev/stderr
#
# Intro message
#
echo ">> Starting container at $(date) with help of $0" >/dev/stderr
#
# Execute one-time startup scripts
#
for fname in /container/docker-entrypoint.d/*.sh;
do
  #
  # Check for myself
  #
  if [ "$0" = "${fname}" ]; then
     continue
  fi
  #
  # Check for excutable script
  #
  if [ -x "${fname}" ]; then
     echo ">> Found script ${fname}" >/dev/stderr
     lfile="${fname/docker-entrypoint.d/rw}.done"
     test -f ${lfile} && echo ">> Ignoring script ${fname}" >/dev/stderr 
     test -f ${lfile} || echo ">> Executing script ${fname}" >/dev/stderr 
     test -f ${lfile} || ${fname} </dev/null >/dev/stdout 2>/dev/stderr && touch ${lfile} && echo ">> Successfully finished ${fname}" >/dev/stderr
     echo ">> Done: Found script ${fname}" >/dev/stderr
  else
     echo ">> Found script ${fname} without execution permissions, ignoring it." >/dev/stderr
  fi
done
echo ">> Running final startup command $@" >/dev/stderr
exec "$@"
echo ">> Done: Starting container at $(date) with help of $0" >/dev/stderr
#
# end-of-container.squid/docker-entrypoint.d/docker-entrypoint.sh
#
