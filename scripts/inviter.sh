#!/usr/bin/env bash
# Læser iO-mailen fra en issue, tjekker domænet og inviterer til organisationen.
# ISSUE_BODY bruges kun som data (grep), aldrig som kode.
set -uo pipefail

ORG="${ORG:-IO-Denmark}"
TILLADTE="${TILLADTE_DOMAENER:-iodigital.com}"
DRY="${DRY_RUN:-}"

svar() { # tekst
  if [ -n "$DRY" ]; then echo "SVAR: $1"; else GH_TOKEN="$ISSUE_TOKEN" gh issue comment "$ISSUE_NUMBER" --body "$1" >/dev/null; fi
}
ryd() { # fjern mailen og luk; forsøg at slette hele issuen
  if [ -n "$DRY" ]; then echo "RYD"; return 0; fi
  GH_TOKEN="$ISSUE_TOKEN" gh issue edit "$ISSUE_NUMBER" --body "Mail fjernet." >/dev/null || true
  if [ -n "${INVITE_TOKEN:-}" ] && [ -n "${ISSUE_NODE_ID:-}" ] &&
     GH_TOKEN="$INVITE_TOKEN" gh api graphql -f query='mutation($id:ID!){deleteIssue(input:{issueId:$id}){clientMutationId}}' -f id="$ISSUE_NODE_ID" >/dev/null 2>&1; then
    return 0
  fi
  GH_TOKEN="$ISSUE_TOKEN" gh issue close "$ISSUE_NUMBER" >/dev/null || true
}

mails="$(printf '%s' "${ISSUE_BODY:-}" | grep -oiE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' | tr 'A-Z' 'a-z' | sort -u)"
antal="$(printf '%s\n' "$mails" | grep -c . || true)"

if [ "$antal" != "1" ]; then
  svar "Skriv præcis én mail i feltet, og opret opgaven igen."; ryd; exit 0
fi
mail="$mails"
domaene="${mail##*@}"
ok=""
IFS=',' read -ra liste <<< "$TILLADTE"
for d in "${liste[@]}"; do [ "$domaene" = "$d" ] && ok=1; done
if [ -z "$ok" ]; then
  svar "Kun iO-mails kan få adgang her. Skriv til Lucas, hvis du mener, det er en fejl."; ryd; exit 0
fi

if [ -n "$DRY" ]; then echo "INVITER: $mail"; svar "Invitationen er sendt."; ryd; exit 0; fi

if out="$(GH_TOKEN="$INVITE_TOKEN" gh api -X POST "orgs/$ORG/invitations" -f email="$mail" -f role=direct_member -F "team_ids[]=${TEAM_ID:?}" 2>&1)"; then
  svar "Invitationen er sendt til den mail, du skrev. Åbn mailen fra GitHub og accepter. Mangler du en GitHub-bruger, så opret en gratis med den samme mail."
else
  echo "Fejl fra GitHub: $out" >&2
  svar "Kunne ikke sende invitationen. Er du allerede medlem, eller ligger der en åben invitation? Ellers skriv til Lucas."
fi
ryd
