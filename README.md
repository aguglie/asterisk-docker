# asterisk-docker PATCHED
[[ https://img.shields.io/docker/build/guglio/asterisk-docker-patched.svg ]]
Aapplied patch in order to show ip after "Failed to 
authenticate device" error, in this way we can better use fail2ban.
As found here: http://www.dslreports.com/forum/r29583253-Asterisk-Attacker-invite-packet-not-captured-by-fail2ban

Dockerfile for building [Asterisk][github/asterisk] as a base for chan_respoke.

This Dockerfile currently builds Debian "jessie" release.  It configures Asterisk 
using the configs from `asterisk/configs/basic-pbx`, also known as the "Super 
Awesome Company" configs.
