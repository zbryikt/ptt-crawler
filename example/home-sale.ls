require! <[fs]>

data = JSON.parse(fs.readFileSync \final.json)

hash = {}
for [author, title] in data
  if not hash[author] => hash[author] = {}
  ret = /^\s*\[([^\]]*)\]/.exec title
  cat = if ret => ret.1 else "----"
  hash[author][cat] = ( if hash[author][cat] => that else 0 ) + 1

# dump normalized data into file
#console.log hash
fs.writeFileSync \normalized.json, JSON.stringify(hash)

buyer  = [x for x of hash]filter -> !hash[it]公告 and hash[it]買屋
seller = [x for x of hash]filter -> !hash[it]公告 and !hash[it]買屋 and hash[it]賣屋
asker  = [x for x of hash]filter -> !hash[it]公告 and !hash[it]買屋 and !hash[it]賣屋 and hash[it]問題

fs.writeFileSync \buyer.txt, buyer.join \\n
fs.writeFileSync \seller.txt, seller.join \\n
fs.writeFileSync \asker.txt, asker.join \\n

