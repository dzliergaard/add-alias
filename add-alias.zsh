#!/usr/bin/zsh

function HELP {
printf "Adds or removes an alias to file ~/.aliases.
If terminal's rc file doesn't source ~/.aliases, adds a line to do so.
If no command provided, prints the current alias.

Usage: add [flags] [alias] [command]

Flags:
  -d:   delete given alias (terminating)
  -h:   print this message (terminating)
"
}

export ALIASES_FILE=$HOME/.aliases

# Init aliases file if it doesn't exist.
if [ ! -e $ALIASES_FILE ]; then
  touch $ALIASES_FILE;
  chmod +x $ALIASES_FILE
fi

# If no args, show help and quit.
if [ $# -eq 0 ]; then
  HELP
  return 0
fi

# Print current mapping for alias in aliases file.
function printAlias() {
  gawk -F= -v"alias=$1" '$1 ~ "alias "alias"=" { print $0 }' $ALIASES_FILE
}

# Remove an alias from aliases file.
function deleteAlias() {
  gawk -F= -v"alias=$1" '$0 !~ "alias "alias"=" { print $0 }' $ALIASES_FILE > $ALIASES_FILE.tmp
  mv $ALIASES_FILE.tmp $ALIASES_FILE
}

# Get current shell rc file, creating if necessary.
# If rc file does not source aliases file, add line to do so.
MYSHELL=`ps -hp $$|awk '{print $5}'`
[[ "$MYSHELL" =~ "(\w*)$" ]] && MYSHELL=$MATCH
RC_FILE="$HOME/.${MYSHELL}rc"
if [ ! -e $RC_FILE ]; then
  touch $RC_FILE
fi
if ! grep --quiet "^source $ALIASES_FILE" $RC_FILE; then
  echo "" >> $RC_FILE
  echo "# add custom aliases" >> $RC_FILE
  echo "source $ALIASES_FILE" >> $RC_FILE
fi

# process flags
OPTIND=0 # needed for getopts to work right when .add-alias is sourced
while getopts d:h opt $argv; do
  case $opt in
    d)
      shift
      printAlias $OPTARG
      [[ -n `alias $OPTARG` ]] && unalias $OPTARG
      echo "Deleting alias $OPTARG."
      deleteAlias $OPTARG
      return 0
      ;;
    h)
      HELP
      return 0
      ;;
    \?)
      HELP
      return 1
      ;;
  esac
done

ALIAS=$1
if [ -z "$ALIAS" ]; then
  HELP
  return 0
fi
shift
COMMAND=$argv

# read out current alias if no new command provided
if [[ -z "$COMMAND" ]]; then
  printAlias $ALIAS
  return 0
fi

# save new alias and sort
echo "Adding alias $ALIAS='$COMMAND'"
deleteAlias $ALIAS
echo "alias $ALIAS='$COMMAND'" >> $ALIASES_FILE
sort $ALIASES_FILE -o $ALIASES_FILE

source $ALIASES_FILE
