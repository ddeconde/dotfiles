
display_cmd_usage () {
  cat << 'EOF'

Usage: cmd [-Bc] [-a a_arg] arg1 ...

  B : do something else
  c : do another optional thing

  a : do something with a_arg

  arg1 : used for something

EOF
}

while getopts ":a:Bch" opt; do
  case "${opt}" in
    a)
      # option -a is set with argument $OPTARG
      ;;
    B)
      # option B is set
      ;;
    c)
      # option c is set
      ;;
    h)
      # print help message
      display_cmd_usage
      ;;
    \?)
      printf "Invalid option: -${OPTARG}\n" >&2
      display_cmd_usage >&2
      exit 1
      ;;
    :)
      printf "Option -${OPTARG} requires an argument.\n" >&2
      display_cmd_usage >&2
      exit 1
      ;;
  esac
done
