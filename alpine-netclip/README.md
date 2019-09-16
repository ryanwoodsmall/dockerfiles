# netclip

network clipboard built on docker with

- alipine linux
- bash
- dropbear ssh
- xclip x11 clipboard client
- xvfb virtual frame buffer x server
- x11vnc vnc server (for debugging)
- those perennial favorites, _**stdin**_ and _**stdout**_
- "last in, only out, maybe" technology

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
# netclip help
usage: /clip [cmd]

  basics:
    export cliphost=hostname.domainname
    ssh -l clippy -p 11922 ${cliphost} /clip install | bash
    cat ~/.bin/id_rsa.pub | netclip addkey
    echo hello | sc
    sp
    cat /tmp/in.txt | netclip copy ; ssh remote 'netclip paste > /tmp/out.txt'

  commands:
          addkey: add an ssh key from stdin
           clear: clear the contents of the clipboard
       clearhist: clear all history entries
     clipboardin: manipulate clipboard selection stdin
    clipboardout: manipulate clipboard selection stdout
            copy: copy stdin to the clipboard
         delhist: read a history entry from stdin and delete it
          delkey: read a key number from stdin and delete it
         delpass: delete the stored password file
     disautolock: disable autolocking the clipboard before copying
         dishist: disable capturing clipboard history
        dumpkeys: copy and paste ssh keys to stdout
      enautolock: enable autolocking the clipboard before copying
          enhist: enable capturing clipboard history
         gethist: read a history entry from stdin and show it
            help: show this help
         install: show install script for netclip/sc/sp
        listhist: list any existing history entries
        listkeys: show known ssh authorized keys
            lock: mark the clipboard as read-only
         netclip: show netclip control script
           paste: paste the clipboard to stdout
       primaryin: manipulate primary selection stdin
      primaryout: manipulate primary selection stdout
            reap: kill any lingering xclip processes
              sc: show network copy script
     secondaryin: manipulate secondary selection stdin
    secondaryout: manipulate secondary selection stdout
         setpass: read new password from stdin
    showautolock: show the clipboard autolocking status
        showhist: show the clipboard history status
        showlock: show the clipboard lock status
        showpass: show password
        showport: show the ssh clipboard port
        showuser: show the ssh clipboard user
              sp: show network paste script
          unlock: mark the clipboard as read-write
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

## setting up a bunch of keys at once

bootstrapping keys is relatively simple assuming they're exchanged with the netclip host

```
git clone https://github.com/ryanwoodsmall/dockerfiles.git
cd dockerfiles/alpine-netclip
docker build --tag netclip .
docker run -d --restart always --name netclip -p 11922:11922 netclip
docker exec --user clippy netclip /clip delpass
docker cp ~/.ssh/id_rsa.pub netclip:/tmp/key.pub
docker exec --user clippy netclip bash -c 'cat /tmp/key.pub | /clip addkey'
docker exec --user clippy netclip /clip install | bash
for h in h01 h02 h03 ; do
  ssh $h cat .ssh/id_rsa.pub | netclip addkey
  netclip install | ssh $h
done
```

### todo

- debug environment var - run vs build time
- debug x11vnc should run as debug user connecting to clippy xvfb? xhost?
- just remove vnc stuff for now?
- watch a fifo?
- read-only flag? write-host check? "only host with IP #.#.#.# can copy"
- or read-only user? read-only port?
- lock down ssh command (requires openssh) similar to git
- remove root user requirement after setup, run as regular user
- make ssh command configurable
- ability to turn ssh password auth off
- ability to update: clip script, startup .sh scripts, and dropbear packages
- peel out unnecessary/big packages
- clear on read, i.e. delete the clipboard when paste
- move clip to its own netclip git project/repo? probably not for now
- something more "enterprise-y" on centos/rhel w/auth (pam, ldap, kerberos, ...) stuff built in
- service discovery for user/host/port (mdns? other broadcast?)
- gui???
- real supervisor instead of shell loops?
- network of clipboards? local service, master service with broadcast, distribution?
- actual c/go/rust service process?
- ssh client mutual auth/verification from server
- lock/unlock around copy? probably, but race-y
  - autolock bool
- multiple clipboards?
  - multiple copy/paste is ugh, complicates input
  - use as undo? implicit/explicit?
  - if clipboard is text, automatically copy to primary?
  - xclip supports primary/secondary/clipboard/buffer-cut
  - xsel supports primary/secondary/clipboard
  - clipboard is any data type, cut buffer is old, primary is "text only", secondary is underdefined
- xclip `-verbose`?
- xsel?
  - more features than xclip
  - `--append` option for stdin to selection
  - `--follow` option for tail-like stdin
  - `--exchange` option for primary/secondary
  - `--logfile` for logging errors
  - `--keep` option for primary/secondary persistence
  - `--verbose` option
- sselp
  - suckless simple x selection printer
  - works on primary, out only
  - https://tools.suckless.org/x/sselp/
- case-generation for function expansion
  - pipes are paresed BEFORE vars in $v1|$v2|$v3) ... case examples
  - ugh
- explicit file copy support?
  - would require "client" code
  - no

### uses

- system monitor?
  - htop/iostat/ifstat/etc. output on secondary
  - aggregate views w/tmux
- ring buffer with sponge
- ripple i/o loops
- broadcast/subscription/todo system?
- combine with
  - pbcopy/pbpaste on macos
  - xclip/xsel on linux
  - hterm utils on chrome os (https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc)
  - ??? on windows
- daemon/service/plugins for whatever programs for centralized clipping

### links

- https://github.com/danielguerra69/alpine-vnc
- https://github.com/jkuri/alpine-xfce4
- https://wiki.archlinux.org/index.php/Clipboard
