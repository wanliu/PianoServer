echo ok

last_commit=$1

git log $last_commit..HEAD  --pretty="%s%n%b" --grep "must_read:"
