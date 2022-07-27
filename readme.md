# Hackbox - Kali Linux Container With GUI

Kali Linux running in the browser with Xfce GUI using noVNC

## Support ❤️

If you find the project useful, please consider supporting, or contributing.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/dubniczky)

## Start Guide

### 1. Get the image

Download from DockerHub

```bash
docker pull detrix/hackbox
```

Or build yourself

```bash
make build
```

### 2. Start the image

Release version

```bash
make box
```

Your local build

### 3. Access the container

You may access the container in two main ways:

1. Through the CLI after issuing the start command. You are given a root ZSH instance.
2. Using a browser client for GUI by navigating to the URL printed to the console (port might differ based on your settings)

```bash
make start
```

### 4. Delete the container

Exit the running console using `Control+C` or typing `exit`. The container is automatically destroyed.

> Remember not to leave any files in the container, as they will be lost.

> Remember to delete the container after each use. Never use it twice.

## Happy Hacking!

I hope you'll find this tool useful!  
Remember to stay stafe in your operations ✌️
