param actionGroupName string

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
  name: actionGroupName

}

output actionGroupId string = actionGroup.id
