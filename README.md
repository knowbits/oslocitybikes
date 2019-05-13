# "Oslo Bysykkel" - Availability status

This project uses the *[Oslo Bysykkel open API](https://oslobysykkel.no/apne-data/sanntid)* to create a list of the **bikes** and **docks** currently available at each of the **bicycle stations** located throughout Oslo.

The application is implemented as a bash script ([citybikestatus.sh](./citybikestatus.sh)) for ease of experimenting and rapid prototyping.

The .json files of the *open API* are updated every 10 seconds, hence a *bash script* is a convenient way to run as a *cron job* every 10 seconds, to create a file listing the latest *availability status* for all stations.

There are two ways of running the *bash script*:
* By using a built-in *bash terminal* on your host machine.
* Alternatively, by using the *Docker image* provided in this project, that enables you to run a *bash terminal* safely (recommended) in a separate container.

## Prerequisite 1: a *bash terminal*

You need a bash terminal to run the bash script.

A bash terminal should already be available by default on <u>Mac</u> and <u>Linux</u>.

### Getting bash on Windows 10: WSL

Bash is easily available on Windows 10, by installing [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10). Different Linux flavours can be used with WSL, they are available in Microsoft Store. Ubuntu is one viable choice, [here](https://linuxhint.com/install_ubuntu_windows_10_wsl/) is how to install it.

Once you have WSL and a Linux variant installed, just type `bash` in the Run-dialog (Win+R) to start a bash terminal. 

<u>Note</u>: provided you have enabled the proper option during WSL/Ubuntu install, you can right-click a folder in Explorer to start a bash terminal in that specific folder.

### Getting bash on older versions of Windows

On older versions of Windows you might want to try Cygwin or GitBash, but none these have been tested yet in this project. Please send a note if you get any of these to work with our bash script. 

### Alternative: run bash scripts safely using the *Docker image*

If any of the above steps to get a bash terminal fail - or you would rather prefer to run the bash script safely in a container (you probably should) - then use this project's "Dockerfile" to build a tailored Docker image. This image provides a "bash terminal" when running it in a container. The image is based on Alpine Linux (5MB), it comes with the "jq" and "curl" packages pre-installed, and also includes the [citybikestatus.sh](./citybikestatus.sh) script. 

1. [Install](https://docs.docker.com/install) Docker on your host machine.
   * On Windows [install](https://docs.docker.com/docker-for-windows/install) the so called "Docker Desktop for Windows". 
     The setup file can be downloaded [here](https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe) (>500MB).
   * Note that Docker uses "Hyper-V" on Windows which does not coexist very well with "Oracle VirtualBox". Hence VirtualBox should be uninstalled prior to installing Docker.  
2. Download [Dockerfile](./Dockerfile) from this project's [repository](https://github.com/knowbits/oslocitybikes) at GitHub.
3. Build the Docker image by typing `docker build --tag image_citybikes .` at the command prompt (in the same folder where you have downloaded *Dockerfile*).
4. Start an interactive "bash terminal" by typing `docker run --rm -i -t image_citybikes`.
   <u>Note</u>: The "--rm" option ensures automatic deletion of the container when you exit it. 
              PS! Type `exit` in the bash terminal to exit the container.

## Prerequisite 2: install *join*, *column*, *jq* and *curl* packages

If you run bash on Windows, Mac or Linux you need to make sure that the the following Linux packages gets installed, since these command line tools are used in our bash script.

* [join](https://linux.die.net/man/1/join) - join lines of two files on a common field. 
* [column](https://linux.die.net/man/1/column) - a utility to "columnate" lists. 
* [jq](https://stedolan.github.io/jq/manual) - a lightweight command-line JSON processor. 
* [curl](https://github.com/curl/curl) - a command-line tool for transferring data specified with URL syntax.

On Linux you typically install a package using a command like `sudo apt-get install <package name>`. See further documentation of *apt-get* [here](https://www.computerhope.com/unix/apt-get.htm).

<u>Note</u>: the *Docker image* comes with the *jq* and *curl* packages pre-installed. 

## Install the application ([citybikestatus.sh](./citybikestatus.sh))

<u>Note</u>: if you intend to use the *Docker image*, you don't need to download [citybikestatus.sh](./citybikestatus.sh) from GitHub, since the image comes with the bash script pre-installed.

Once you have a *bash terminal* available on your host machine, then download the [citybikestatus.sh](./citybikestatus.sh) bash script, from the [GitHub repository](https://github.com/knowbits/oslocitybikes) to a local folder (named *SCRIPT_FOLDER*) on your host machine. 

## Usage

1. Start a *bash terminal*:
   * If you run *bash* on your *local host*: start bash in *SCRIPT_FOLDER* 
     (the folder where you downloaded [citybikestatus.sh](./citybikestatus.sh)).
   * Alternatively, if you have chosen to use the *Docker image* (see build instructions above), then type `docker run --rm -it image_citybikes` to get a *bash terminal* that runs in a separate Docker container. 

2. Run the script by typing`./citybikestatus.sh`
   * This will print the current *availability status* as a list of "stations, available bikes and available docks" to the terminal window (STDOUT).
   * <u>Note</u>: the output is a "pretty printed" list of 3 columns; *"STATIONS   #BIKES    #DOCKS"*.
   * <u>Note</u>: to save the script output (STDOUT) to a file then type ```./citybikestatus.sh > result.txt```

### Notes
* The bash script creates a set of *intermediate files* during execution. 
  These files are located in the folder *./temp_output/*, and are named sequentially "1a_<>, 1b_<>,...2a_<>, 2b_<>, etc". They are useful for debugging during development.
* If you need access to the pretty printed "availability status", it is already available in this file; *./temp_output/4a_station_name_and_availability_PRETTY_PRINTED.txt*
* If you have chosen to run [citybikestatus.sh](./citybikestatus.sh) using the *Docker image* and need to access the output on your "local host machine", then you need to use the *"docker logs"* command from a second "local terminal window".
  * The `docker logs --follow ctnr_citybikes` command will continuously stream any new output from the container’s STDOUT and STDERR. More info [here](https://docs.docker.com/engine/reference/commandline/logs/).
  
    <u>Note</u>: to use *"docker logs"* like this the container first needs to be *named* during start up by typing; `docker run --rm -i -t --name=ctnr_citybikes image_citybikes`

## Built With

* [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) - a Unix shell and command language.
* [jq](https://stedolan.github.io/jq) - a lightweight command-line JSON processor.
  * [Tutorial](https://stedolan.github.io/jq/tutorial), [Manual](https://stedolan.github.io/jq/manual), [Options](https://stedolan.github.io/jq/manual)
* [Oslo Bysykkel open API](https://oslobysykkel.no/apne-data/sanntid).
* [Online JSON viewer](http://jsonviewer.stack.hu) - view JSON documents online, as a tree strucuture of nodes.
* [Visual Studio Code](https://code.visualstudio.com/) - the development environment used.
* Markdown (.md files) related resources
  * [Typora](https://typora.io) - a Markdown editor / reader for Mac, Windows and Linux.
  * [Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet), [GitHub's Guide](https://guides.github.com/features/mastering-markdown/)([PDF](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)).
  * Our aim is to make our Markdown documents adhere to the [GitHub Flavored Markdown](https://github.github.com/gfm/) in a future release.

## Contributing
Pull requests are welcome. 
For major changes, please open an issue first to discuss what you would like to change.

## Authors

* [Erlend Bleken](https://github.com/knowbits) - *Initial work*.

* [Contributors](https://github.com/knowbits/oslocitybikes/contributors) who participated in this project.

## License
This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) license - see the [LICENSE](./LICENSE) file for details.

## About the README file
This file is based on the README template provided by [Make a README](https://www.makeareadme.com).
