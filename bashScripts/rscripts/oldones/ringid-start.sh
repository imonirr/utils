#!/bin/bash

cd /home/server/Projects/UDPServer/dist && java -jar UDPServer.jar >>/home/server/logs/ringid.log 2>&1 &
