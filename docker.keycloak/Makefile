#
# ident "@(#)$Id: Makefile | Sun Aug 11 15:22:43 2024 +0200 | scgu0003 @ rz-nx-01  $"
# $Author: scgu0003 @ rz-nx-01 <scgu0003@h-ka.de> $
#
# Copyright 2024 (c) Guenther Schreiner <guenther.schreiner@smile.de>
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
#      Prepare the common setups for OS base configuration.
#
# Configuration:
#       @see Constants
#
##
## Constants
##
#
# Define the name of myself
#
ME=$(MAKEFILE_LIST)
#
# Define the name of environment file .env
#
ENVFILE=.env
#
# Define the prefix name of config file
#
CONFFILEPREFIX=configuration/runtime_local_
#
# Define the prefix name of config file
#
HOSTNAME=`uname -n`
#
# Define the default config file
#
CONFFILE_DEFAULT=$(CONFFILEPREFIX)SAMPLEHOST$(ENVFILE)
CONFDIR_DEFAULT=$(CONFFILEPREFIX)SAMPLEHOST
#
# Define the host-specific config file and directory
#
CONFFILE=$(CONFFILEPREFIX)$(HOSTNAME)$(ENVFILE)
CONFDIR=$(CONFFILEPREFIX)$(HOSTNAME)
#
###
### Main
###
## ================================================================================
#
# Preparation target
#
all::
	@echo " "
	@echo "$(ME): ## ################################################################################"
	@echo "$(ME): preparing configuration."
	@-if [ -L $(ENVFILE) ]; then rm -f $(ENVFILE); fi
	@-if [ -f $(ENVFILE) ]; then mv $(ENVFILE) $(ENVFILE).misc; fi
	@-if [ -f $(CONFFILE) ]; then echo "$(ME):  using config file $(CONFFILE)"; ln -s $(CONFFILE) $(ENVFILE); fi
	@-if [ ! -f $(CONFFILE) ]; then echo "$(ME):  WARNING: no host-specific config file ($(CONFFILE)) found."; fi
	@-if [ ! -f $(CONFFILE) ]; then echo "$(ME):  using default config file $(CONFFILE_DEFAULT)"; ln -s $(CONFFILE_DEFAULT) $(ENVFILE); fi
	@echo "$(ME): done preparations."
	@echo "$(ME): ## ################################################################################"
	@echo " "
	@echo "$(ME): ## ################################################################################"
	@echo "$(ME): preparing mandatory docker networks."
	@-docker network inspect frontend >/dev/null 2>&1 ||    { docker network create frontend ;   echo "$(ME): created network frontend." ; }
	@-docker network inspect backend >/dev/null 2>&1 ||    { docker network create backend ;   echo "$(ME): created network backend." ; }
	@echo "$(ME): done preparations."
	@echo "$(ME): ## ################################################################################"
	@echo " "
#
# Localization target
#
localize::
	@echo " "
	@echo "$(ME): ## ################################################################################"
	@echo "$(ME): preparing localized configuration."
	@if [ -f $(CONFFILE) ]; then echo "$(ME):  config file $(CONFFILE) exists, aborting."; exit 1; fi
	@echo "$(ME):  creating config file $(CONFFILE) by copying..."
	@-cp -p $(CONFFILE_DEFAULT) $(CONFFILE)
	@-mkdir -p  $(CONFDIR)
	@echo "$(ME):  creating config parameter files within $(CONFDIR) by copying..."
	@-cp -p $(CONFDIR_DEFAULT)/* $(CONFDIR)/
	@echo "$(ME): done preparations."
	@echo "$(ME): ## ################################################################################"
	@echo " "
#
# Cleanup target
#
clean::
	@echo " "
	@-if [ -L $(ENVFILE) ]; then rm -f $(ENVFILE); fi
#
## ################################################################################
#
# end-of-Makefile
#
