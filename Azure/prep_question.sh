#!/bin/bash

TheQuestion="$*"
echo "{
    \"THE_QUESTION\":\"${TheQuestion}\"
}" > question.json
