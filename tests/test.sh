#!/usr/bin/env bash
# Tørkørsel af inviter.sh med forskellige issue-tekster.
set -u
cd "$(dirname "$0")/.."
fejl=0
t() { # navn forventet-tekst body
  out="$(DRY_RUN=1 ISSUE_BODY="$3" bash scripts/inviter.sh)"
  if printf '%s' "$out" | grep -qF -- "$2"; then echo "ok   $1"; else echo "FEJL $1"; echo "$out"; fejl=1; fi
}
t "gyldig"           "INVITER: lucas.hansen@iodigital.com" $'### Din iO-mail\n\nLucas.Hansen@iodigital.com'
t "forkert domæne"   "Kun iO-mails"                        $'### Din iO-mail\n\nnogen@gmail.com'
t "lignende domæne"  "Kun iO-mails"                        $'### Din iO-mail\n\nx@iodigital.com.evil.dk'
t "to mails"         "præcis én mail"                      $'a@iodigital.com b@iodigital.com'
t "ingen mail"       "præcis én mail"                      $'### Din iO-mail\n\n_No response_'
t "samme mail to gange" "INVITER: a@iodigital.com"         $'a@iodigital.com\nA@iodigital.com'
t "shell-forsøg"     "INVITER: a@iodigital.com"            $'a@iodigital.com $(touch /tmp/pwnd) `id`'
[ -e /tmp/pwnd ] && { echo "FEJL kode blev kørt"; fejl=1; }
exit $fejl
