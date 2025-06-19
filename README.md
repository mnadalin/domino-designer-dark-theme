# HCL Domino Designer dark theme

The dark theme for HCL Domino Designer is inspired by VSCode style.  
The provided configuration will style Lotusscript, Java and JavaScript sources on:
- Agents
- Script libraries
- Java sources

## Installation

Close your HCL Domino Designer and Notes client, and backup the entire directory:

```<Notes Data Directory>\workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings```

Clone this repository and open a **PowerShell** Windows Terminal. Move to the repo directory then type:

`.\DominoDarkTheme.ps1`

Restart your Domino Designer and enjoy!

![Domino Designer dark theme](https://github.com/mnadalin/domino-designer-dark-theme/blob/main/domino-designer-dark-theme.png?raw=true)

## Troubleshooting

In case you are getting the error:

`File .\DominoDarkTheme.ps1 cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.`

Then temporarily allow script execution:

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

And run the script once again.

## Disclaimer

The theme was tested on Designer version 12 and 14.5.  
The author is not responsible for any damage or malfunction caused by the instructions and/or configuration files provided.