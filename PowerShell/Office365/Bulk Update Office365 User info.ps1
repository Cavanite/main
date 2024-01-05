#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

Import-Csv .\data.csv -Delimiter ';' | foreach{Set-MsolUser -UserPrincipalName $_.UserPrincipalName -Office $_.Office -Department $_.Department -Title $_.title  -PhoneNumber $_.PhoneNumber -Country $_.Country -UsageLocation $_.UsageLocation }