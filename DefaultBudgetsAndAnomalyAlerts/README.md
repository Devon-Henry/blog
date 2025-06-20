# Introduction

This build includes:

- 2x Policy Definitions
- 1x Policy Initiative (Policy Set Definition)
- 1x Policy Assignment with system managed Identity
- 1x Role Assignment to Management Group


The Policy Definitions are as follows:

- Deploy a Budget
- Deploy a Anomaly Alert

### Deploy a Budget:

The 'budget.json' file includes the policy definition for the budget deployment policy. This policy should be assigned at the management group scope. It will target all 'subscription' resources under the targets management group.

It will then assess if the subscriptions have a budget set that matches exactly the following:

- Budget Amount
- Time Grain (Monthly, Annually, etc.)
- Cost (rather than usage)

If a budget exists that matches the above (set in param file) then subscriptions are compliant. If a budget does not, then you must run a remediation task and the subcsription is non-compliant.

### Deploy a Anomaly Alert:

The 'anomaly-alert.json' file include the policy definition for the anomaly alert deployment policy. This policy should be assigned at the management group scope. It will target all 'subscription' resources under the targets management group.

It will then assess if the subscriptions have an anomaly alert set that matches exactly the following:

- alertDisplayName

If an anomaly alert exists that matches the above (set in param file) then subscriptions are compliant. If a anomaly alert does not, then you must run a remediation task and the subcsription is non-compliant.

## Changing Values

To change the values of the deployed Budgets and Anomaly alerts. Go to the 'main.prod.bicepparam' file. There you will see all the editable parameters.

**Deployment management group must be configures in the 'bicep-deploy.ps1' file**

**TIP**: Hover your mouse over the parameter name and a description will appear (those with specific allowed values will show you them too)

## Useful Source Material

- [Scheduled Actions - ARM Template](https://learn.microsoft.com/en-us/azure/templates/microsoft.costmanagement/scheduledactions?pivots=deployment-language-arm-template)
- [Budget Template](https://www.azadvertizer.net/azpolicyadvertizer_all.html?policyId=Deploy-Budget)
- [Policy Definition Pattern](https://learn.microsoft.com/en-us/azure/governance/policy/samples/pattern-deploy-resources)
- [Learn - Anomaly Alerts](https://learn.microsoft.com/en-us/azure/cost-management-billing/understand/analyze-unexpected-charges#create-an-anomaly-alert)


Reach out if you have any questions or need any clarification.


