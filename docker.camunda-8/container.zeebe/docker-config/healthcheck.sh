#!/bin/bash
timeout 10s bash -c ':> /dev/tcp/127.0.0.1/9600' || exit 1 