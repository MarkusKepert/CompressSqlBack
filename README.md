# CompressSqlBack
In adition to Ole halegrens SQL Maintaninace Solution, i've created a script that compress the backup files (bak and trn)

## Installation instructions
- install PCLogging powershell module https://www.powershellgallery.com/packages/PSLogging/2.5.2
- install scripts in Backup root folder
- Edit Drive letter and Paths in backup.cmd and AgentJob_BackupRAR.cmd
- get 7za from http://www.7-zip.de/ and extract in backup directory
- Exec AgentJob_BackupRAR.cmd via SQL Server JOB Agent
