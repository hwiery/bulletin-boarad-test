#!/bin/bash

# TSBOARD 자동 설정 스크립트 (127.0.0.1 사용)
echo "127.0.0.1
root

tsboard
tsb_
3306
10
10

Yes
admin@example.com
admin123
" | ./goapi-mac 