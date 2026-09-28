---
name: manage-cloudflare
description: Manage Cloudflare DNS, tunnels, and zones via the API. Loads credentials from dotfiles and uses the Cloudflare API. Use when working with DNS records, Cloudflare Tunnels, Zero Trust, firewall rules, or any Cloudflare resource.
compatibility: Bash, curl, flarectl, cloudflared
---

# Cloudflare Management

## Credentials

Account email: `germangarayadriel@hotmail.com`

Load the API token at the start of every session:

```bash
source ~/Github/dotfiles/.password-store/credentials.env
# Token is now in $CLOUDFLARE_TOKEN_GMAIL_ACCOUNT
export CF_API_TOKEN="$CLOUDFLARE_TOKEN_GMAIL_ACCOUNT"
export CF_API_EMAIL="germangarayadriel@hotmail.com"
```

Verify the token works:

```bash
curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" | jq '.result.status'
# Should return "active"
```

---

## Common Operations

### List zones

```bash
curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" | jq '.result[] | {id, name, status}'
```

### Get zone ID for a domain

```bash
DOMAIN="example.com"
ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  | jq -r '.result[0].id')
echo $ZONE_ID
```

### List DNS records for a zone

```bash
curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  | jq '.result[] | {id, type, name, content, proxied}'
```

### Create a DNS record

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "sub.example.com",
    "content": "1.2.3.4",
    "ttl": 1,
    "proxied": true
  }' | jq '.success, .result.id'
```

### Update a DNS record

```bash
RECORD_ID="<record_id>"
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"content": "5.6.7.8"}' | jq '.success'
```

### Delete a DNS record

```bash
curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" | jq '.success'
```

---

## Cloudflare Tunnels

### List tunnels

```bash
ACCOUNT_ID=$(curl -s "https://api.cloudflare.com/client/v4/accounts" \
  -H "Authorization: Bearer $CF_API_TOKEN" | jq -r '.result[0].id')

curl -s "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  | jq '.result[] | {id, name, status}'
```

### Get tunnel config (ingress rules)

```bash
TUNNEL_ID="<tunnel_id>"
curl -s "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
  -H "Authorization: Bearer $CF_API_TOKEN" | jq '.result.config.ingress'
```

---

## Using flarectl (if installed)

```bash
export CF_API_TOKEN="$CLOUDFLARE_TOKEN_GMAIL_ACCOUNT"
export CF_API_EMAIL="germangarayadriel@hotmail.com"

flarectl zone list
flarectl dns list --zone example.com
flarectl dns create --zone example.com --type A --name sub --content 1.2.3.4
```

---

## Notes

- The token variable in credentials.env is `CLOUDFLARE_TOKEN_GMAIL_ACCOUNT`
- Always prefer `Authorization: Bearer $CF_API_TOKEN` over API key auth
- `proxied: true` enables Cloudflare proxy (orange cloud); `false` is DNS-only
- TTL `1` means "auto" when proxied; use `3600` for DNS-only records
- Changes propagate in seconds for proxied records, up to TTL for DNS-only
