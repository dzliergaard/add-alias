# add-alias
Adds or removes an alias to file ~/.aliases.
If terminal's rc file doesn't source ~/.aliases, adds a line to do so.
If no command provided, prints the current alias.

# Usage

`add [flags] [alias] [command]`

Flags:
  -d:   delete given alias (terminating)
  -h:   print this message (terminating)

## Notes

To enable aliases being available immediately upon adding them, make sure to source the .add-aliases script, or simply add an alias to do so:

`alias add="source ~/bin/.add-alias"
