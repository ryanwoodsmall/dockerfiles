# netclip

network clipboard built on docker with

- alipine linux
- bash
- dropbear ssh
- xvfb virtual frame buffer x server
- x11vnc vnc server (for debugging)
- those perennial favorites, _**stdin**_ and _**stdout**_

## usage

the `install` command will setup three scripts in `${HOME}/bin`

- `netclip`: netclip service interaction/control
- `sc`: shared clipboard copy
- `sp`: shared clipboard paste

environment variables

var | purpose | default
--- | --- | ---
`clipuser` | netclip ssh user | clippy
`clipport` | netclip ssh port | 11922
`cliphost` | netclip hostname/IP | docker container id
`clipinst` | netclip script installation path | `${HOME}/bin`

```
$ netclip help

/clip: usage

  /clip [cmd]

  commands:
       addkey: add an ssh key from stdin
        clear: clear the contents of the clipboard
    clearhist: clear all history entries
         copy: copy stdin to the clipboard
      delhist: read a history entry from stdin and delete it
       delkey: read a key number from stdin and delete it
      delpass: delete the stored password file
      dishist: disable capturing clipboard history
     dumpkeys: copy and paste ssh keys to stdout
       enhist: enable capturing clipboard history
      gethist: read a history entry from stdin and show it
         help: show this help
      install: show install script for netclip/sc/sp
     listhist: list any existing history entries
     listkeys: show known ssh authorized keys
      netclip: show netclip control script
        paste: paste the clipboard to stdout
         reap: kill any lingering xclip processes
           sc: show network copy script
      setpass: read new password from stdin
     showpass: show password
     showport: show the ssh clipboard port
     showuser: show the ssh clipboard user
           sp: show network paste script
```

## building

```
docker build --tag netclip .
```

## run

```
docker run -d --restart always --name netclip -p 11922:11922 netclip
```

## username/password

the username/password for ssh access is dumped to the logs at startup

```
docker logs netclip | awk -F: '/^user:/{print $NF}' | head -1 | tr -d ' '
docker logs netclip | awk -F: '/^pass:/{print $NF}' | head -1 | tr -d ' '
```

the ssh/vnc password can be shown using the `showpass` command as well

```
docker exec --user clippy netclip /clip showpass
```

the ssh password can be reset from the docker host where netclip is running

```
docker exec --user clippy netclip sh -c 'echo SuperSecretNEWp@55W0rD+ | /clip setpass'
```

the password file can be removed

```
docker exec --user clippy netclip /clip delpass
```

## add an ssh key

substitute username/port/hostname below

enter password when prompted

```
cat ~/.ssh/id_rsa.pub | ssh -l clippy -p 11922 hostname /clip addkey
```

test keys with

```
ssh -l clippy -p 11922 hostname /clip help
```

## get scripts

automatic install

```
export cliphost=hostname
ssh -l clippy -p 11922 ${cliphost} /clip install | bash
```

manual install

```
export cliphost=hostname
ssh -l clippy -p 11922 ${cliphost} /clip netclip > ~/bin/netclip
chmod 755 ~/bin/netclip
~/bin/netclip sc > ~/bin/sc
~/bin/netclip sp > ~/bin/sp
chmod 755 ~/bin/s{c,p}
which -a netclip sc sp
```

## use scripts

set a hostname for `${cliphost}` and copy/paste to your heart's content

```
export cliphost=hostname
echo something | sc
sp
```

that's it!

once a host's key is in place it has full copy/paste powers as long as the cliphost is reachable

### todo

- debug environment var - run vs build time
- watch a fifo?
- read-only flag? write-host check? "only host with IP #.#.#.# can copy"
- or read-only user? read-only port?
- lock down ssh command (requires openssh) similar to git
- remove root user requirement after setup, run as regular user
- make ssh command configurable
- ability to turn ssh password auth off
- ability to update - clip script, .sh scripts, and dropbear packages

### links

- https://github.com/danielguerra69/alpine-vnc
- https://github.com/jkuri/alpine-xfce4
