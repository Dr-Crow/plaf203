#!/bin/sh

JKsh_echo_info()
{
    echo -e "\033[40;36m$1\033[0m"
}

JKsh_echo_warn()
{
    echo -e "\033[40;33m$1\033[0m"
}

JKsh_echo_err()
{
    echo -e "\033[40;31m$1\033[0m"
}
