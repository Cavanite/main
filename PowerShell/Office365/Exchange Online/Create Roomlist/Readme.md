# Creating a Room List using PowerShell

This guide will walk you through the process of creating a room list using PowerShell.

## Prerequisites

- PowerShell v5.1 or later
- Exchange Online Management PowerShell v2 module

## Steps

1. **Connect to Exchange Online**

   Open PowerShell and run the following command to connect to Exchange Online:

   ```powershell
   Connect-ExchangeOnline -UserPrincipalName <UPN> -ShowProgress $true
   ```

   Replace `<UPN>` with your User Principal Name.

2. **Create a Distribution Group**

   Run the following command to create a distribution group:

   ```powershell
   New-DistributionGroup -Name <GroupName> -RoomList
   ```

   Replace `<GroupName>` with the name you want for your room list.
   Make user you are not using any Special Charachter in the displayname or Primair SMTP adress. like: ( ) [ ]
   Otherwise your Roomlist will not working

3. **Add Rooms to the Distribution Group**

   Run the following command to add rooms to your distribution group:

   ```powershell
   Add-DistributionGroupMember -Identity <GroupName> -Member <RoomName>
   ```

   Replace `<GroupName>` with the name of your room list and `<RoomName>` with the name of the room you want to add.

## Conclusion

You have now created a room list using PowerShell. You can add as many rooms as you want to your room list by repeating step 3.

## Troubleshooting

If you encounter any issues, please check the following:

- Ensure you have the correct permissions to create distribution groups and add members.
- Ensure the room you are trying to add exists and is not already in the group.
```

Please replace `<UPN>`, `<GroupName>`, and `<RoomName>` with your actual User Principal Name, Group Name, and Room Name respectively.