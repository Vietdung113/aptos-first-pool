# aptos-first-pool

**Compile Move module**

```
move build
```

**Test Move module**

```
move test
```
**Publish Move module**
+ Step 1: Commend addresses in `Move.toml`
+ Run command
```
aptos move publish --named-addresses vault=YOUR_ADDRESS
```
eg:
```
aptos move publish --named-addresses vault=0xd4e0fedf4b4b742db4a2f2a721d746cdbfe9b598911d81e21ca5034aaa61481e
```


   
