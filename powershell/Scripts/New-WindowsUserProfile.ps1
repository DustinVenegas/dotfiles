param(
    [string]$UserName
)

$methodName = 'UserEnvCP'
$script:nativeMethods = @();

Register-NativeMethod "userenv.dll" "int CreateProfile([MarshalAs(UnmanagedType.LPWStr)] string pszUserSid,`
  [MarshalAs(UnmanagedType.LPWStr)] string pszUserName,`
  [Out][MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszProfilePath, uint cchProfilePath)";

Add-NativeMethods -typeName $MethodName;

$localUser = New-Object System.Security.Principal.NTAccount("$UserName");
$userSID = $localUser.Translate([System.Security.Principal.SecurityIdentifier]);
$sb = new-object System.Text.StringBuilder(260);
$pathLen = $sb.Capacity;

Write-Verbose "Creating user profile for $Username";
try
{
    [UserEnvCP]::CreateProfile($userSID.Value, $Username, $sb, $pathLen) | Out-Null;
}
catch
{
    Write-Error $_.Exception.Message;
    break;
}
