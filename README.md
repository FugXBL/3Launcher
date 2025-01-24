# 3Launcher

![image](https://github.com/user-attachments/assets/7eada112-9a74-4918-9e27-9c93cdddcc93)

## Introduction

**3Launcher** is a powerful and user-friendly batch script designed to automate the setup of save files and configurations for Call of Duty: Black Ops 3. It eliminates the manual effort required to manage saves, particularly for the **Microsoft Store version**, which involves several complicated steps to get saves working. To use this script, just extract the source code zip file anywhere, I prefer to have it in my Documents folder.

This script also allows you to create **presets**, enabling you to easily switch between different save files or game configurations by simply opening the shortcuts it generates.

## Features

- **Automated Save Management**: Handles copying and replacing save files with ease.
- **Windows BO3 Compatibility**: Automates the complex setup process for the Microsoft Store version, including disabling the internet if required.
- **Steam & BOIII Client Compatibility**: Simplifies save file management for the Steam version and works seamlessly with the BOIII client.
- **Preset System**: Create, manage, and load different configurations with unique shortcuts. These shortcuts can be moved over to the desktop after creation.
- **Admin Privilege Detection**: Ensures the script requests administrator privileges when necessary.
- **Customizable Options**:
  - Option to disable the internet for Microsoft Store setups.
  - Option to start the script or shortcuts as an administrator.
- **Smart Error Handling**: Detects missing folders or files and provides helpful guidance.

## How It Works

### Microsoft Store Version
The script is especially useful for the **Microsoft Store version** of BO3, which requires several manual steps to get save files working:
1. Some brute forcing may be required to successfully set up the save file. This includes deletion of the wgs folder, disabled WiFi, and the save files to be set to read-only.
2. The script automates this process and attempts to execute all actions for you.  
   **Note**: Administrator privileges may be required for the internet to be disabled. After creating a preset, it is recommended to:
   - Right-click the generated shortcut.
   - Go to **Properties > Shortcut > Advanced** and check **Run as Administrator**.

### Steam Version & BOIII Client
The script works seamlessly with both the Steam version and the BOIII client:
- For the BOIII client:
  - Select the **Steam version** option during the script setup.
  - Provide the paths for the BOIII client executable and its player folder during the setup prompts.
  - This allows the script to work with the BOIII client just like the Steam version.

### Save Management
1. To add save files, **create a folder under the `Saves` folder** (located in the script directory).
2. Copy and paste your save files into the newly created folder.
3. The script will inject the save files from the `Saves` folder into the appropriate BO3 `players` folder upon running.

### Presets
With this script, you can:
- Create shortcuts for different saves or versions of BO3.
- Quickly switch between configurations by opening the appropriate shortcut.

## Usage

1. **Run the Script**: Double-click the batch file to start.
2. **Follow the Prompts**:
   - Specify your version of BO3 (Steam, Microsoft Store, or BOIII client by selecting Steam).
   - Provide the necessary folder paths (e.g., save location, game executable).
   - Choose whether to disable the internet for the Microsoft Store version.
   - Create a preset with unique names.
   - You can now reconfigure the settings and create a new preset if you wish to do so. Alternatively, you could just launch the script directly from the interface.
3. **Use Shortcuts**:
   - The script generates shortcuts in the `Presets` folder.
   - Double-click a shortcut to load the corresponding configuration.

## Requirements

- Windows OS.
- Administrator privileges may be required for some actions (e.g., disabling the internet).
- A valid copy of Call of Duty: Black Ops 3 (Steam, Microsoft Store version, or BOIII client).

## License

This script is distributed under the **MIT License**. See the `LICENSE` file for more details.

## Disclaimer

This script is provided "as is". Use it at your own risk. The script may modify game files, and the creator is not responsible for any potential issues arising from its use.

---

![image](https://github.com/user-attachments/assets/7cd04a13-a00d-42df-8f93-65d8221a27f4)

Enjoy effortless BO3 save management!
