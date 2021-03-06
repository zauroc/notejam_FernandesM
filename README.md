# Azure App Service Deployment
This is a basic Azure Web App infrastructure deployment ready for a .Net V4.0 application using Terraform V0.14.8 . It will be automatically deploy 3 enironments Prod, Dev and UAT:
Azure Resource Group,
Azure App Service Plan with App Services auto-scaling,
Azure App Service with deployment slots with Staging and Last Good for DEV and UAT environments,
Application Insights,
Azure SQL Server with databases,
Azure storage account for SQL audit,
Azure Storage account for Azure Monitor,
Azure KeyVault,
Azure Loganalythics workspace.

![image](https://user-images.githubusercontent.com/81716894/113217161-6a77d800-9275-11eb-98bf-8dd0e4a9160a.png)
For more details in the design please visit: https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/app-service-web-app/basic-web-app?tabs=cli

# Deployment Notes

Clone this repository

Make sure you have access to an active Azure subscription

Using Visual Studio code open the cloned GitHub folder

In Visual Studio code open a new terminal

Type az login to login to your subscription in Azure 

Make sure terraform CLI is installed using the command:    terraform

Initialize terraform Azure modules using the command:    terraform init

Plan and save the infra changes into tfplan file using the command:    terraform plan -out tfplan

Apply the infrastructure changes with command:    terraform apply tfplan -auto-approve

Destroy the infrastructure deployed:    terraform destroy 

Enjoy





