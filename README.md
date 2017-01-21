# Testing eduVPN & Let's Connect!
VPN software can probably only be really tested with real-world users with real-world traffic. But since we also want to run stress tests ourselves, we created (more like hacked together) some scripts to spin up large quantities of LXC-containers that visit the web through eduVPN. 

All the scripts in this repository are well... hacked together. Don't run these nodes on publically available servers, or even beter: don't run these scripts at all. It's a first try, later it might be more reliable and secure.

## Our requirements
Basically we want to run a lot of web surfing VPN clients at the same time. 

## Used components
Since [LXC containers](https://linuxcontainers.org/) are very lightweight on resources they are excellent for our use case. In addition, some of us already use [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-ve) as their hypervisors, so LXC containers make even more sense. 

We use the Debian 8.6.0 LXC container template and configure it with a script. This is all very hacky and is certainly not the way it should be done. The script installs [OpenVPN](https://packages.debian.org/jessie/openvpn) and downloads the eduVPN testenvironment configuration file from a local webserver. It then creates a VPN connection to our server, and executes the web traffic script ([cURL](https://curl.haxx.se/) based).

## Generating web traffic
The current web traffic script is really crappy. It is based on an average user that has been recorded with the Chrome Developer Tools (Network -> Record). This recording has been converted to cURL with sleep commands in between to repeat our guinea pig. We want to create a couple of profiles with different behaviours, something like:

| User | Description |
| --- | --- |
| Basic user | visits some websites, downloads a file occasionly, reads and sents a few e-mails. |
| Power user | visits a lot of websites, downloads bigger files more often. |
| Youtube-addict | watches a lot of videos online. |
| Downloader | uses VPN for downloading torrents and NZB's. |
| Instagram-addict | watches a lot of pictures online. |
