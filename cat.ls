require! <[fs prelude-ls]>

if process.argv.length < 3 =>
  console.log "usage: lsc cat.ls [board-name]"
  console.log "example: lsc cat.ls food"
  process.exit!
board = process.argv.2

files = fs.readdir-sync "data/#board/post"
hash = {}
for file in files
  file = "data/#board/post/#file"
  if not /\.html/.exec file => continue
  lines = fs.read-file-sync file .to-string!split \\n
  author = /^\s*作者\s+(\S+)/.exec lines.1
  title = /^\s*標題\s+(.+)/.exec lines.3
  if not (author and title) => continue

  # now we have author and title
  [author,title] = [author.1,title.1]
  #console.log title
  cat = /^\s*\[([^\]]+)/.exec title
  if not cat => continue

  # now we have category
  cat = cat.1

  for line in lines =>
    email = /^\s*(?:\[必\])?\s*聯絡方式[:：]\s+(?:.*?)([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)/.exec line
    if email =>
      email = email.1
      break
    email = /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)/.exec line
    if email =>
      email = email.1
      break
  if email => email = email.replace /\//g, ""
  hash.[][cat]push [author,email]
list = [item for item in hash[\譯者]]
list = list.sort (a,b) -> if a[1] => 1 else -1
console.log ["#{item.0} #{item.1}" for item in list]join \\r\n
#console.log ["#{item.0} #{item.1}" for item in hash[\譯者]]join \\r\n
