#!/bin/bash
echo "Hadoop Starting..."
start-dfs.sh
ssh hadoop102 'source /etc/profile&&start-yarn.sh'