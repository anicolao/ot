# Operator Trees

To get started with this repository, add these aliases to your
environment:

```bash
function catot {
	curl https://raw.githubusercontent.com/anicolao/ot/$1
}

function execot {
	TMPFILE=$(mktemp)
	catot $1 > $TMPFILE
	shift
	chmod +x $TMPFILE
	$TMPFILE $*
	rm $TMPFILE
}

function ot {
	execot bin/setup
}
```

Then run `ot` to enter.
