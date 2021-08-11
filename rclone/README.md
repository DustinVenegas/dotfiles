# rclone

[rclone](https://github.com/rclone/rclone) is software that can mount remote and Cloud storage as a local filesystem. rclone can upload and download data as a one-time operation, synchronize files locally, or provide an on-demand FUSE mount, aka your Google Drive gets mounted as the X:\ drive.

## Installation

Install Windows dependencies using Chocolatey.

```bash
choco install chocolatey-packages.config
```

Create the service by running bootstrap.ps1 in an administrator shell.

```ps1
.\bootstrap.ps1
```

Remove the service by running the following PowerShell command in an Administrator Prompt.

```ps1
Remove-Service rclone-gdrive
```

## Setup rclone

### Setup Google Drive

<https://rclone.org/drive/>

#### Create a service account for example.com

A service account creates a sandbox account to provide OAuth2 and personal limits. This method allows rsync to use an OAuth2 token for fine-grained file-access on servers. Using a sandbox account ensures that rsync does not hit web service limits as easily - by default, a globally shared account among all users is used.

* To create a service account and obtain its credentials, go to the Google Developer Console.
* You must have a project - create one if you don’t.
* Then go to “IAM & admin” -> “Service Accounts”.
* Use the “Create Credentials” button. Fill in “Service account name” with something that identifies your client. “Role” can be empty.
* Tick “Furnish a new private key” - select “Key type JSON”.
* Tick “Enable G Suite Domain-wide Delegation”. This option makes “impersonation” possible, as documented here: Delegating domain-wide authority to the service account
* These credentials are what rclone will use for authentication. If you ever need to remove access, press the “Delete service account key” button.

#### Allowing API access to example.com Google Drive

* Go to the example.com admin console
* Go into “Security” (or use the search bar)
* Select “Show more” and then “Advanced settings”
* Select “Manage API client access” in the “Authentication” section
* In the “Client Name” field enter the service account’s “Client ID” - this can be found in the Developer Console under “IAM & Admin” -> “Service Accounts”, then “View Client ID” for the newly created service account. It is a ~21 character numerical string.
* In the next field, “One or More API Scopes”, enter <https://www.googleapis.com/auth/drive> to grant access to Google Drive specifically.

#### Configure rclone, assuming a new install

```sh
rclone config
```

```sh
n/s/q> n         # New
name>gdrive      # Gdrive is an example name
Storage>         # Select the number shown for Google Drive
client_id>       # Can be left blank
client_secret>   # Can be left blank
scope>           # Select your scope, 1 for example
root_folder_id>  # Can be left blank
service_account_file> /home/foo/myJsonfile.json # This is where the JSON file goes!
y/n>             # Auto config, y
```

#### Verify that it’s working

The arguments do:

* -v - verbose logging
* --drive-impersonate foo@example.com - this is what does the magic, pretending to be user foo.
* lsf - list files in a parsing friendly way
* gdrive:backup - use the remote called gdrive, work in the folder
        named backup.

```sh
    rclone -v --drive-impersonate foo@example.com lsf gdrive:backup
```
