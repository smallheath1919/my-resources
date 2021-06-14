#Author: Srijit Bose
#CreatedOn: 2021-06-15
#License: GNU GPL v3
#Parameters
Param (
    [string]$resource, #resource type. Not Mandatory. Defines the type of resource you want to list. Default {Resource Groups, All Resources}
    [string]$options #Additional options to az $resource list command
)
#Generating query string
$qstring=$("[?tags.CreatedBy == '"+$(az ad signed-in-user show --query mailNickname -o tsv)+"' || tags.CreatedBy == '"+$(az ad signed-in-user show --query userPrincipalName -o tsv)+"' || tags.CreatedBy == '"+$(az ad signed-in-user show --query displayName -o tsv)+"' ]")

#Default case {Resource Groups, All resources}
if ($resource.Length -lt 1) {
    echo "Resource Groups:"
    az group list --query "$qstring" -o table $options
    echo " "
    echo "Resources:"
    az resource list --query "$qstring" -o table $options
}
#Case where resources are defined
else {
    $resource=$('az '+ $resource+' list --query "'+$qstring+'" -o table '+$options)
    Invoke-Expression $resource > tmpmyresource.txt
    if ($(get-content tmpmyresource.txt).Length -lt 1)    {
        echo "No resources found"
    }
    else {
        get-content tmpmyresource.txt
    }
    rm tmpmyresource.txt
}
