New-AdUser -Name 'oozkaya'
-GivenName  'Ozcan'
-Surname 'Ozkaya'
-DisplayName 'oozkaya'
-ChangePasswordAtLogon $true
-UserPrincipalName 'oozkaya@comapny.pri'
-Department 'IT'
-Manager 'manegername-here'
-AccountPassword (ConvertTo-SecureString '$Password' -AsPlainText -Force)
-Enabled $true