# Adgang til iO's Claude-marketplace

Er du ansat hos iO, og skal du have adgang til iO's plugins til Claude?

1. Opret en gratis GitHub-bruger på github.com, hvis du ikke har en.
2. Opret en opgave her under **Issues → New issue → Adgang**, og skriv din iO-mail.
3. Få en mail fra GitHub inden for et minut, og tryk **Join**.
4. Fortsæt i vejledningen fra Lucas.

Kun mails på `@iodigital.com` får en invitation. Mailen i opgaven fjernes efter behandling.

## Teknik

`scripts/inviter.sh` kører i GitHub Actions, når en opgave oprettes. Den læser mailen, tjekker domænet og kalder `POST /orgs/IO-Denmark/invitations`. Hemmeligheden `ORG_INVITE_TOKEN` ligger som repo-secret. Test: `bash tests/test.sh`.
