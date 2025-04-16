# mcserver-docker-manager
Automated backup, RCON management, Docker integration and Minecraft server startup.

This repository contains scripts to manage a Minecraft server using Docker, including automated backups, RCON management and starting the server with Docker Compose. The goal of this project is to simplify the process of running a Minecraft server within a Docker container.

---

## Features

- **Automated backups**: Run backups before and after starting the server. 
- **RCON Management**: with mcrcon
- **Docker Integration**: Set up and run your Minecraft server in a Docker container.

---

## Requirements

- **Docker**: [Install Docker](https://www.docker.com/get-started)
- **docker-minecraft-server**: You will need the `docker-minecraft-server` image by itzg for running the server inside Docker. [Learn more](https://github.com/itzg/docker-minecraft-server).
- **mcrcon** needed for RCON. [Learn more](https://github.com/Tiiffi/mcrcon)
- **Windows**

---

## Setup

### Step 1: Install Docker

[Install Docker](https://www.docker.com/get-started)

### Step 2: Set up your Minecraft server using Docker

You can use the `docker-minecraft-server` image by **itzg**, which is a pre-configured Docker image for Minecraft servers [docker-minecraft-server](https://github.com/itzg/docker-minecraft-server).

### Step 3: Configure Docker Compose

Make sure to include the following lines in your `docker-compose.yml` file (or use the template provided in this repository):

```yaml
ports:
  - "25565:25565"      # MC Server port
  - "25575:25575/tcp"  # RCON port (mcrcon)
  - "19132:19132/udp"  # Bedrock Edition port - useful with geyser
environment:
  EULA: "TRUE"  # Agree to Minecraft EULA
volumes:
  - YOUR_MINECRAFT_SERVER_FOLDER:/data  # Adjust this path
working_dir: /data
restart: "no"
```

### Step 4: Edit the Backup Scripts and `serverstart.bat`

- **Backup Scripts**:
  - Edit the `pre_backup.ps1` and `post_backup.ps1` scripts to adjust the backup directory and save location.

```powershell
$serverFolder = "C:\Path\to\backup" # this folder is the one getting copied
$backupFolder = "C:\Path\to\backup" # this folder is the save file location
```

```
SET PROCESS_PATH="C:\Program Files\Docker\Docker\Docker Desktop.exe"    :: Default Docker location

SET CONTAINER_NAME=YOUR_CONTAINER_NAME     :: Replace with your container name, e.g. "minecraft"
```

Depending on how fast (or slow) or how many mods and plugins your server has you might want to increase or decrease 'timeout /t 45 >nul'. If you use too little RCON fails to connect and you need to start the .bat again. 45 sec is safe, but might take too long for people with good hardware.
```
    timeout /t 45 >nul
```


Replace YOUR_SERVER_IP with your server IP (Host is fine if running server on local machine) and YOUR_RCON_PASSWORD with your RCON password
```
mcrcon -H YOUR_SERVER_IP -P 25575 -p YOUR_RCON_PASSWORD
```
## Usage

To use the Minecraft server manager, follow the steps below:

0. **FIRST:**
   - Make sure all the files are in the same directory OR make sure you refer to the right directory.
   - Scripts are NOT ready to run, you need to adjust the scripts according to your specific needs.

1. **Start the server:**
   - Run the `serverstart.bat` file. It will check if Docker is running and start the server if necessary.
   
2. **Backup the server:**
   - The backup process is automatic and will be triggered before and after the server starts. The backup files are stored in the specified directory.

3. **RCON connection:**
   - After starting the server, it will automatically log in to RCON using the specified credentials.
   - You can interact with the server directly from the terminal.
   - Make sure to adjust timeout /t 45 >nul according to your own timing

4. **Stop the server:**
   - To stop the server, you can type `stop` in the RCON terminal or stop it via Docker commands or just close the logs cmd window, it will close the server.

5. **Customizing the scripts:**
   - Edit the `pre_backup.ps1` and `post_backup.ps1` scripts to adjust backup paths and settings according to your needs.
   - Modify the `serverstart.bat` to include the correct RCON credentials and names.

## Notes

- Ensure that you have Docker installed and configured correctly.
- The `docker-compose.yml` file should be set up properly for the Minecraft server to run inside the Docker container.
- You need to adjust paths and scripts for compatibility with your machine.
- The backup process is fully automated and will run both before and after the server starts to ensure data safety.
- The backup does not backup .jar files in the folder plugins to save space. you can change that in the ps1 script
- The `start.bat` file opens the server logs in one terminal window and connects to RCON in a split terminal window. If you close the logs window, the server wilt close aswell
- For more advanced configurations or troubleshooting, consult the [docker-minecraft-server repository](https://github.com/itzg/docker-minecraft-server).
- Just a little spare time project of mine, change and do whatever you want to improve it ^^

## Disclaimer:

These scripts use components and images from third-party repositories, including but not limited to the [docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) by itzg and [Tiiffi](https://github.com/Tiiffi/mcrcon). The rest of the code in this repository is created by Me (Endrycio).

**Use at your own risk and make back-ups.** The authors are not responsible for any damages, data loss, or other issues that may arise from using this software and/or script(s).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Copyright:
This project includes the use of third-party software from the [docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) by itzg, which is distributed under the Apache License 2.0 and the [Tiiffi](https://github.com/Tiiffi/mcrcon) distributed under zlib license.

For the third-party components:
- [docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) 
-  [Tiiffi](https://github.com/Tiiffi/mcrcon) 

If you have questions or concerns about this code or wish to contribute, feel free to do so. 

## Acknowledgements

This project makes use of [docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) by itzg and [Tiiffi](https://github.com/Tiiffi/mcrcon) BUT does NOT include any code or software from itzg and/or Tiiffi, it simply refers to the tool made by itzg and Tiiffi. The Tiiffi software is distributed under the [zlib License](https://opensource.org/licenses/Zlib).

Please refer to the mcrcon or docker-minecraft-server repository for more details and its respective licensing information.
