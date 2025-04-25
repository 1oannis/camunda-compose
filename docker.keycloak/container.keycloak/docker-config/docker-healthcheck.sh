#!/bin/sh -x
#
# ident "@(#)$Id: docker-healthcheck.sh | Sat Nov 18 14:46:21 2023 +0100 | UnknownUser @ MacBook-Air-GS-6.local  $"
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
#      Script to check health of container operation.
#
# The HEALTHCHECK instruction tells Docker how to test a container to
# check that it is still working. This can detect cases such as a web server
# that is stuck in an infinite loop and unable to handle new connections,
# even though the server process is still running.
# 
# When a container has a healthcheck specified, it has a health status in
# addition to its normal status. This status is initially starting. Whenever
# a health check passes, it becomes healthy (whatever state it was previously in).
# After a certain number of consecutive failures, it becomes unhealthy.
#
# The command exit status indicates the health status of the container. The possible values are:
#
#    0: success - the container is healthy and ready for use
#    1: unhealthy - the container is not working correctly
#    2: reserved - do not use this exit code
#
###
### Constants
###
# 
# Define the number of expected daemons
#
NUM_OF_SERVICES=1
# 
# Define the expected daemon name
#
SERVICE_NAME=java
# 
###
### Main
###
#
# Count the intended processes and compare the number with the desired count
#
test $(cat /proc/[1-9]*/comm | grep "$SERVICE_NAME" | wc -l) -ge "$NUM_OF_SERVICES"
#
# Pass success as exit status.
#
exit $?
#
# end-of-container.mariadb/docker-config/docker-healthcheck.sh
#
