#!/bin/bash

source ~/.proxy
URL="https://graph.microsoft.com/v1.0/me/mailfolders/inbox/messages?$select=subject,from,receivedDateTime&$top=25&$orderby=receivedDateTime%20DESC"
URL="https://graph.microsoft.com/v1.0/me/messages?$select=sender,subject"
curl -X GET "${URL}"

echo ""

# Authorization endpoint - used by client to obtain authorization from the resource owner.
https://login.microsoftonline.com/<issuer>/oauth2/v2.0/authorize
# Token endpoint - used by client to exchange an authorization grant or refresh token for an access token.
https://login.microsoftonline.com/<issuer>/oauth2/v2.0/token

# NOTE: These are examples. Endpoint URI format may vary based on application type,
#       sign-in audience, and Azure cloud instance (global or national cloud).

#       The {issuer} value in the path of the request can be used to control who can sign into the application. 
#       The allowed values are **common** for both Microsoft accounts and work or school accounts, 
#       **organizations** for work or school accounts only, **consumers** for Microsoft accounts only, 
#       and **tenant identifiers** such as the tenant ID or domain name.
