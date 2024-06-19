#!/bin/sh

g_watching_flag="/tmp/user_watching"

JKsh_led_init()
{
    echo $G_LED_GPIO > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio$G_LED_GPIO/direction
}

JKsh_led_ctrl()
{
    # don't change link led #
    if [ -e $g_watching_flag ];then
        return
    fi

    if [ $G_LED_BRIGHT_LEVEL = "low" ];then
        val=$((1 - $1))
    else
        val=$1
    fi

    echo $val > /sys/class/gpio/gpio$G_LED_GPIO/value
}

