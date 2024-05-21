# Import specific methods and models from other libraries
# from azure.mgmt.resource import SubscriptionClient
# from azure.identity import AzureCliCredential
# from azure.mgmt.resource import ResourceManagementClient
# from azure.mgmt.resource import SubscriptionClient
from azure.identity import ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient

# Create a client object for the subscription
SUB1="SUBSCRIPTION"
TENANT_ID="TENANT"
CLIENT_ID="CLIENT_ID"
CLIENT_SECRET="CLIENT_SECRET"

credential = ClientSecretCredential(
    tenant_id=TENANT_ID,
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET
)

client = ResourceManagementClient(credential, SUB1)

# Retrieve the list of resource groups in the subscription
rg = [i for i in client.resource_groups.list()]

# Retrieve the list of resources in each resource group
rg_resources = {}
for i in range(0, len(rg)):
    rg_resources[rg[i].as_dict()["name"]] = client.resources.list_by_resource_group(
        rg[i].as_dict()["name"],
        expand="properties,created_time,changed_time"
    )

# Print the details of each resource
for i in rg_resources.keys():
    details = []
    for _data in iter(rg_resources[i]):
        a = _data
        details.append(client.resources.get_by_id(vars(_data)['id'], 'latest'))
    print(details)
