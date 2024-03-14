1. Create first S3 & DynamoDb resources (backend.tf)
2. Create any resources in main.tf (e.g ec2) for your infrastructure
3. Apply "terraform init" & plan & apply   ( Resources will be created in AWS but state file "terraform.tfstate" will be locally)
4. In order to move state file to remote (S3) declare remote state configuaration inside terraform {} block in provide.tf 
5. Apply "terraform init" to make changes . Will ask you move state file from locally to remote (S3)
6. Changes made in Infrastructure will upadte in remote state file
7. If you want to move state configurtion from remote to locally, uncomment configuartions (point no. 4) and Apply "terraform init" & "terraform init -migrate-state"  
8. You can delete resource (s3 & DyanamoDB) if you want but Object(state file) inside S3 should be manually deleted for S3 bucket resource