# netclip

network clipboard

## building

```docker build --tag netclip```

## run

```docker run -d --restart always --name netclip -p 11922:11922 netclip```

## get username/password

```
docker logs netclip | awk -F: '/^user:/{print $NF}' | head -1 | tr -d ' '
docker logs netclip | awk -F: '/^pass:/{print $NF}' | head -1 | tr -d ' '
```

## add an ssh key

substitute username/port/hostname below

enter password when prompted

```cat ~/.ssh/id_rsa.pub | ssh -l clippy -p 11922 hostname /clip addkey```

test with

```ssh -l clippy -p 11922 hostname /clip help```

## get scripts

```
ssh -l clippy -p 11922 hostname /clip netclip > ~/bin/netclip
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
$ ssh -l clippy -p 11922 localhost /clip help
/clip: usage

  /clip [cmd]

  commands:
      addkey: add an ssh key from stdin
        copy: copy stdin to the clipboard
      delkey: read a key number from stdin and delete it
     dishist: disable capturing clipboard history
      enhist: enable capturing clipboard history
        help: show this help
    listkeys: show known ssh authorized keys
     netclip: show netclip control script
       paste: paste the clipboard to stdout
          sc: show network copy script
     setpass: read new password from stdin
    showpass: show password
          sp: show network paste script
```
