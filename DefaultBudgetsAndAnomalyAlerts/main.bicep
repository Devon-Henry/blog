targetScope = 'managementGroup'

//////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Global - Params and Variables //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

var policyBudgetDef = loadJsonContent('budget.json')
var policyAnomalyDef = loadJsonContent('anomaly-alert.json')

@description('An array of email strings to be notified upon alert firing')
param contactEmailsArr array
@description('The first percentage where an alert will be fired on actual budget hit (don\'t include %)')
param firstActualThreshold string
@description('The second percentage where an alert will be fired on actual budget hit (don\'t include %)')
param secondActualThreshold string
@description('The first percentage where an alert will be fired on actual budget hit (don\'t include %)')
param firstForecastThreshold string
@description('The second percentage where an alert will be fired on actual budget hit (don\'t include %)')
param secondForecastThreshold string
@description('The 100% Threshold for the budget in £')
param amount string

@description('The time period you want the budget to report on')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
  'BillingMonth'
  'BillingQuarter'
  'BillingAnnual'
])
param timeGrain string

@description('The name of the budget that shows in Cost Management')
param budgetName string
@description('The name of the action group you want to assign to the budget alerts')
param actionGroupName string 
@description('The name you want displayed in Azure for this Policy Assignment')
param policyAssignmentDisplayName string 
@description('The description you want displayed in Azure for this Policy Assignment')
param policyAssignmentdescription string
@description('The subscription ID of the action group you want to assign to the budget alerts')
param actionGroupSubID string
@description('The name of the resource group of the action group you want to assign to the budget alerts')
param actionGroupResourceGroup string 
@description('The name of the Anomaly Alert, and what the deployment condition is based on')
param alertDisplayName string
@description('Email address of the point of contact that should get the unsubscribe requests and notification emails.')
param notificationEmail string
@description('Frequency of the schedule for the Anomaly Alerts, evaluation period')
@allowed([
  'Daily'
  'Monthly'
  'Weekly'
])
param scheduleFrequency string

//////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// Resources //////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////



module actionGroup 'module/action-group.bicep' = {
  scope: resourceGroup(actionGroupSubID, actionGroupResourceGroup)
  params: {
    actionGroupName: actionGroupName
  }
}

resource policyBudgetDefinition 'Microsoft.Authorization/policyDefinitions@2025-01-01' = {
  name: 'Standard Budget Deployment Policy Definition'
  properties: policyBudgetDef
}
resource policyAnomalyDefinition 'Microsoft.Authorization/policyDefinitions@2025-01-01' = {
  name: 'Standard Anomaly Deployment Policy Definition'
  properties: policyAnomalyDef
}


resource policyAssignment 'Microsoft.Authorization/policyAssignments@2025-01-01' = {
  name: 'Subsc-Budget-Policy'
  location: 'uksouth'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    policyDefinitionId: policyInitiative.id
    displayName: policyAssignmentDisplayName
    description: policyAssignmentdescription
    parameters: {
      contactGroups: {
        value: [actionGroup.outputs.actionGroupId] 
      }
      contactEmails: {
        value: contactEmailsArr  
      }
      firstActualThreshold: {
        value: firstActualThreshold  
      }
      secondActualThreshold: {
        value: secondActualThreshold
      }
      firstForecastThreshold: {
        value: firstForecastThreshold  
      }
      secondForecastThreshold: {
        value: secondForecastThreshold
      }
      amount: {
        value: amount
      }
      timeGrain: {
        value: timeGrain
      }
      budgetName: {
        value: budgetName
      }
      recipients: {
        value: contactEmailsArr
      }
      alertDisplayName: {
        value: alertDisplayName
      }
      scheduleFrequency: {
        value: scheduleFrequency
      }
      notificationEmail: {
        value: notificationEmail
      }
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(guid(managementGroup().id, policyAssignment.id, 'contributor'))
  properties: {
    roleDefinitionId: managementGroupResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: policyAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  
  }
}

resource policyInitiative 'Microsoft.Authorization/policySetDefinitions@2025-01-01' = {
  name: 'Budget-Policy-Initiative'
  properties: {
    displayName: 'Budget-Policy-Initiative'
    description: 'Budget-Policy-Initiative'
    policyType: 'Custom'
    metadata: {
      category: 'Budget'
    }
    parameters: {
      alertDisplayName: {
            type: 'String'
            defaultValue: alertDisplayName
            metadata: {
                displayName: 'Alert Display Name'
                description: 'The display name of the insight alert.'
            }
        }
        notificationEmail: {
            type: 'String'
            defaultValue: notificationEmail
            metadata: {
                displayName: 'Notification Email'
                description: 'Email addresses to notify'
            }
        }
        scheduleFrequency: {
            type: 'String'
            defaultValue: scheduleFrequency
            metadata: {
                displayName: 'Schedule Frequency'
                description: 'Frequency of the alert'
            }
        }
        recipients: {
            type: 'Array'
            defaultValue: contactEmailsArr
            metadata: {
                displayName: 'Notification Recipients'
                description: 'List of email addresses to notify.'
            }
        }
        budgetName: {
            type: 'String'
            defaultValue: budgetName
            metadata: {
                description: 'The name for the budget to be created'
            }
        }
        amount: {
            type: 'String'
            defaultValue: amount
            metadata: {
                description: 'The total amount of cost or usage to track with the budget'
            }
        }
        timeGrain: {
            type: 'String'
            defaultValue: timeGrain
            allowedValues: [
                'Monthly'
                'Quarterly'
                'Annually'
                'BillingMonth'
                'BillingQuarter'
                'BillingAnnual'
            ]
            metadata: {
                description: 'The time covered by a budget. Tracking of the amount will be reset based on the time grain.'
            }
        }
        firstActualThreshold: {
            type: 'String'
            defaultValue: firstActualThreshold
            metadata: {
                description: 'Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000.'
            }
        }
        secondActualThreshold: {
            type: 'String'
            defaultValue: secondActualThreshold
            metadata: {
                description: 'Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000.'
            }
        }
        firstForecastThreshold: {
            type: 'String'
            defaultValue: firstForecastThreshold
            metadata: {
                description: 'Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000.'
            }
        }
        secondForecastThreshold: {
            type: 'String'
            defaultValue: secondForecastThreshold
            metadata: {
                description: 'Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000.'
            }
        }
        contactRoles: {
            type: 'Array'
            defaultValue: [
                'Owner'
                'Contributor'
            ]
            metadata: {
                description: 'The list of contact RBAC roles in an array to send the budget notification to when the threshold is exceeded.'
            }
        }
        contactEmails: {
            type: 'Array'
            defaultValue: []
            metadata: {
                description: 'The list of email addresses in an array to send the budget notification to when the threshold is exceeded.'
            }
        }
        contactGroups: {
            type: 'Array'
            defaultValue: []
            metadata: {
                description: 'The list of action groups in an array to send the budget notification to when the threshold is exceeded. It accepts array of strings.'
            }
        }
    }
    policyDefinitions: [
      {
        policyDefinitionId: policyAnomalyDefinition.id
        policyDefinitionReferenceId: 'Standard Anomaly Deployment Policy Definition'
        parameters: {
          recipients: {
            value: contactEmailsArr
          }
          alertDisplayName: {
            value: alertDisplayName
          }
          scheduleFrequency: {
            value: scheduleFrequency
          }
          notificationEmail: {
            value: notificationEmail
          }
        }
      
      }
      {
        policyDefinitionId: policyBudgetDefinition.id
        policyDefinitionReferenceId: 'Standard Budget Deployment Policy Definition'
        parameters: {
          contactGroups: {
        value: [actionGroup.outputs.actionGroupId] 
      }
      contactEmails: {
        value: contactEmailsArr  
      }
      firstActualThreshold: {
        value: firstActualThreshold  
      }
      secondActualThreshold: {
        value: secondActualThreshold
      }
      firstForecastThreshold: {
        value: firstForecastThreshold  
      }
      secondForecastThreshold: {
        value: secondForecastThreshold
      }
      amount: {
        value: amount
      }
      timeGrain: {
        value: timeGrain
      }
      budgetName: {
        value: budgetName
      }

        }
      
      }
    ]
  }
}


