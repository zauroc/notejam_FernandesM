# Azure App Service Deployment
This is a basic Azure Web App infrastructure deployment ready for a .Net V4.0 application using Terraform V0.14.8 . It will be automatically deployed:
Azure Resource Group,
Azure App Service Plan,
Azure App Service for PROD with deployment slots DEV and UAT,
Azure SQL Server with databases for PROD, DEV and UAT,
Azure storage account for SQL audit,
Azure KeyVault,
Azure Loganalythics workspace.

![image](https://user-images.githubusercontent.com/81716894/113217161-6a77d800-9275-11eb-98bf-8dd0e4a9160a.png)

# Deployment notes
Clone this repository

Make sure you have access to an Azure subscription

Using Visual Studio code open the cloned GitHub folder

Type az login to login to your subscription in Azure 

Make sure terraform CLI is installed using the command:    terraform

Initialize terraform Azure modules using the command:    terraform init

Plan and save the infra changes into tfplan file using the command:    terraform plan -out tfplan

Apply the infrastructure changes with command:    terraform plan tfplan

Enjoy





