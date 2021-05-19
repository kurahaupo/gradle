#!/bin/bash

# Bash all the way back to v2.05 has read with -p and -s
# where both -s and -p are ignored if stdin isn't a tty.

read -p 'Enter username: ' username || exit
read -p 'Enter password: ' -s password || exit

printf '\n'

if [ "$username" = "secret-user" ] && [ "$password" = "secret-password" ] ; then
    echo "Welcome, $username!"
else
    echo "Bad credentials!"
    exit 1
fi
