# netclip

network clipboard

## building

```
docker build --tag netclip .
```

## run

```
docker run -d --restart always --name netclip -p 11922:11922 netclip
```

## get username/password

```
docker logs netclip | awk -F: '/^user:/{print $NF}' | head -1 | tr -d ' '
docker logs netclip | awk -F: '/^pass:/{print $NF}' | head -1 | tr -d ' '
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
```

## use scripts

set a hostname and copy/paste to your heart's content

```
export cliphost=hostname
echo something | sc
sp
```

that's it!

### usage

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
       enhist: enable capturing clipboard history
      gethist: read a history entry from stdin and show it
         help: show this help
      install: show install script for netclip/sc/sp
     listhist: list any existing history entries
     listkeys: show known ssh authorized keys
      netclip: show netclip control script
        paste: paste the clipboard to stdout
           sc: show network copy script
      setpass: read new password from stdin
     showpass: show password
     showport: show the ssh clipboard port
     showuser: show the ssh clipboard user
           sp: show network paste script
```
