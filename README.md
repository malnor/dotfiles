Before starting the installation, make sure that the $HOME (Environment variables for the user) has been set. To setup HOME use (for example to the user profile folder):

```
PS > setx $HOME $env:UserProfile
```
The above command will set an environment variable reachable by $HOME and visible in the Environment variables. This variable setting is required for installation of git.


```
PS > Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/malnor/dotfiles/master/Bootstrap.ps1'))
```


