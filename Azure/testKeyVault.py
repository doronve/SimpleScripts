import os
import sys
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

keyVaultName = os.environ["KEY_VAULT_NAME"]
KVUri = f"https://{keyVaultName}.vault.azure.net"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KVUri, credential=credential)

#secretName = input("Input a name for your secret > ")
#secretValue = input("Input a value for your secret > ")
#secretName = "secretName"
#secretValue = "secretValue"
secretName = sys.argv[1] if len(sys.argv)>1 else "secretName" 
secretValue = sys.argv[2] if len(sys.argv)>2 else "secretValue" 


print(f"Creating a secret in {keyVaultName} called '{secretName}' with the value '{secretValue}' ...")

client.set_secret(secretName, secretValue)

print(" done.")

print(f"Retrieving your secret from {keyVaultName}.")

retrieved_secret = client.get_secret(secretName)

print(f"Your secret is '{retrieved_secret.value}'.")
print(f"Deleting your secret from {keyVaultName} ...")

poller = client.begin_delete_secret(secretName)
deleted_secret = poller.result()

print(" done.")

print("Get all secrets.")
# Get all secrets
secrets = client.list_properties_of_secrets()

# Loop through the secrets and print their names and values
for secret in secrets:
    secret_value = client.get_secret(secret.name).value
    print(f"secret name = {secret.name}")

#    print(f"{secret.name}: {secret_value}")

print(" done.==============================================================")
