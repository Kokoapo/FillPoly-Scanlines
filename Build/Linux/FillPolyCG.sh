#!/bin/sh
echo -ne '\033c\033]0;FillPolyCG\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/FillPolyCG.x86_64" "$@"
