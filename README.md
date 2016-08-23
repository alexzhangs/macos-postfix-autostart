# macos-postfix-autostart

Auto start postfix when user logged into Mac OS X.

There's no simple way to set postfix auto-start since Mac OS X EI
Capitan (10.11). It's why this repo exists.

EI Capitan intruduced a new feature, SIP (System Integrity
Protection). It marks all files under /System as `restricted`, and no
way to change them by user even with `sudo`.

## Installation

```
git clone https://github.com/alexzhangs/macos-postfix-autostart
sudo sh macos-postfix-autostart/install.sh

macos-postfix-autostart-setup.sh
```
