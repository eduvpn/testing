# Testing eduVPN & Let's Connect!
VPN software can probably only be really tested with real-world users with real-world traffic. But since we also want to run stress tests ourselves, we created (more like hacked together) some scripts to spin up large quantities of LXC-containers that visit the web through eduVPN. 

All the scripts in this repository are well... hacked together. Don't run these nodes on publically available servers, or even beter: don't run these scripts at all. It's a first try, later on it might be more reliable and secure.

## Our requirements
Basically we want to run a lot of web surfing VPN clients at the same time. 

## Used components
Since [LXC containers](https://linuxcontainers.org/) are very lightweight on resources they are excellent for our use case. In addition, some of us already use [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-ve) as their hypervisors, so LXC containers make even more sense. 

We use the Debian 8.6.0 LXC container template and configure it with a script. This is all very hacky and is certainly not the way it should be done. The script installs [OpenVPN](https://packages.debian.org/jessie/openvpn) and downloads the eduVPN testenvironment configuration file from a local webserver. It then creates a VPN connection to our server, and executes the web traffic script ([cURL](https://curl.haxx.se/) based).

## Generating client traffic
The current traffic script is really crappy. It is based on an average user that has been recorded with the Chrome Developer Tools (Network -> Record). This recording has been converted to cURL with sleep commands in between to repeat our guinea pig's every move. In the future we would like a couple of profiles with different behaviours, something like:

| User | Description |
| --- | --- |
| Basic user | visits some websites, downloads a file occasionly, reads and sents a few e-mails. |
| Power user | visits a lot of websites, downloads bigger files more often. |
| Youtube-addict | watches a lot of videos online. |
| Downloader | uses VPN for downloading torrents and NZB's. |
| Instagram-addict | watches a lot of pictures online. |

## Setting up container environment
You should have a properly configured Proxmox host setup in order for these scripts to work. Maybe later we will also make a more universal version of the scripts.

There are two kinds of nodes, client nodes and controller nodes. Client nodes can have one of the aforementioned profiles.

1. Create controller node<br>Configure (variables in script) and run `create_controller_node.sh`. This node will control all the client nodes, so you will be executing commands and scripts primarily from this node. It is advisable to give it some more resources than the client nodes. In our tests 1 core with 512 MB of memory per 125-150 nodes works fine. You should also make the parallel-ssh hosts files now.
2. Create webserver node<br>Configure (variables in script) and run `create_webserver_node.sh`. This node wil host all the configuration files, scripts etc. for the client nodes to download. The webserver mostly consists of really small files, so a simple machine with 1 core and 512 MB of memory will suffice more than fine.
3. Create client nodes<br>Configure (variables in script) and run `create_client_nodes.sh`. The needed resources depend on how you use them. For our use cases, 1 core and 512 MB of memory is enough. The only really CPU intensive commands we use are apt install and apt upgrade.
4. Update nodes<br>Go to your new controller node with ssh (ssh user@ip) or with `pct enter containerID` and change directory to `/root/scripts`. The containers are made and running, but need to get updated. Configure the variables in the script and run `update_nodes.sh`.
5. Install software<br>Now configure the variables in the script and run `install_client_nodes`. This will install the chosen software on the nodes. In our case, it's mostly just openvpn, curl and some other tools.
6. Add profile<br>It is time to add profiles to the nodes. (updated later)
