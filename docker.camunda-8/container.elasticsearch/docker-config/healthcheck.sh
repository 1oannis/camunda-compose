#!/bin/bash
curl -f http://localhost:9200/_cat/health | grep -q green 