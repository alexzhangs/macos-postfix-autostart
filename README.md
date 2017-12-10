# macos-postfix-autostart

This repo is no longer maintained. You can still use it with EI
Capitan, but with High Sierra you don't need it any more, here's why:

    1. There's no need to set postfix auto-start for macOS High
    Sierra. postfix service will be started on demand while calling
    sendmail. That's what I see.

    2. The SIP(metioned below) goes further to prevent system service to
    be unloaded by launchctl. That makes you can't load the copied
    service with the same name. Or even giving a new name and load it
    successfully, while calling it, system log is saying there's
    conflict service detected and the original one(from /System) will
    be used.
    
    What happens with Sierra? I don't know, it's untested.


Here is what this repo was about:

Auto start postfix when user logged into Mac OS X.

There's no simple way to set postfix auto-start since Mac OS X EI
Capitan (10.11). It's why this repo exists.

EI Capitan intruduced a new feature, SIP (System Integrity
Protection). It marks all files under /System as `restricted`, and no
way to change them by user even with `sudo`.

Tested on Mac OS X EI Capitan (10.11).

## Installation

```
git clone https://github.com/alexzhangs/macos-postfix-autostart
sudo sh macos-postfix-autostart/install.sh

macos-postfix-autostart-setup.sh
```
