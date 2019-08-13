#!/bin/bash
stop-dfs.sh
ssh hadoop102 'source /etc/profile&&stop-yarn.sh'