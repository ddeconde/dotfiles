#!/usr/bin/env bash

options() {
    printf "opt1\nopt2\nopt3"
}

suboptions() {
    read opt <&0
    case $opt in
        "opt1") printf "do1\ndo2";;
        "opt2") printf "do3\ndo4";;
        "opt3") printf "do5\ndo6";;
        "*") printf "wrong"
esac
}

options | dmenu | suboptions | dmenu
