require! <[fs request]>

if process.argv.length < 3 =>
  console.log "usage: lsc crawler.ls [board-name]"
  console.log "example: lsc crawler.ls food"
  process.exit!
board = process.argv.2
data = []
request = request.defaults jar: true
jar = request.jar!
cookie = request.cookie "over18=1"

post-done = ->
  console.log "fetch post done. "

fetch-article = (i) ->
  #console.log i, url
  while true =>
    if not fs.exists-sync "data/#board/post/#i.html" => break
    i++
  if i >= data.length => return post-done!
  url = "http://www.ptt.cc#{data[i]2}"
  jar.set-cookie cookie, url
  request {url,jar}, (e,r,b) ->
    if b => 
      c = b.index-of '<div id="main-container">'
      if c => b = b.substring c
      b = b.replace /(<\/?div[^>]*>\s*)+/g, \\n
      b = b.replace /<\/div>/g, \\n
      b = b.replace /<[^>]+>/g, " "
      console.log "post", i, (b or "")length, e, r.status-code
      if e or r.status-code != 200 =>
        return set-timeout (-> fetch-article (if r.status-code==404 => i + 1 else i)), 2000
      fs.write-file-sync "data/#board/post/#i.html", b
    else i = i - 1
    return if i == data.length - 1 => post-done! else set-timeout (-> fetch-article i + 1), 11

post-list-done = (i) -> 
  console.log "fetch post list done, total #{data.length} posts."
  console.log "fetching posts..."
  fs.write-file-sync "data/#board/post-list.json", JSON.stringify({i, data})
  fetch-article 0

fetch-list = (i) ->
  url = "http://www.ptt.cc/bbs/#board/index#i.html"
  jar.set-cookie cookie, url
  request {url, jar}, (e,r,b) ->
    if r =>
    console.log "list", i, e, (if r => r.status-code else "no response")
    if e or !r or r.status-code != 200 => 
      return if r and (r.status-code == 404 or r.status-code == 500) => 
        post-list-done i
      else set-timeout (-> fetch-list i), 2000
    lines = b.replace /(\\t)+/g .split \\n
    for line in lines
      ret1 = /a href="([^"]+)">(.+)<\/a>\s*$/.exec line
      ret2 = /<div class="author">([^<]+)</.exec line
      if not (ret1 or ret2) => continue
      if ret1 => [href,title] = ret1[1,2]
      if ret2 => author = ret2.1
      if author and title =>
        data.push [author, title, href]
        [author, title, href] = [null,null,null]
    if (i % 100) == 0 =>
      console.log "(write current result: #i records)"
      fs.write-file-sync "data/#board/post-list.json", JSON.stringify({i, data})
    set-timeout (-> fetch-list i + 1), 10

if !fs.exists-sync("data") => fs.mkdir-sync "data"
if !fs.exists-sync("data/#board") => fs.mkdir-sync "data/#board"
if !fs.exists-sync("data/#board/post") => fs.mkdir-sync "data/#board/post"

console.log "fetching board '#board'..."

index = 0
if fs.exists-sync("data/#board/post-list.json") =>
  console.log "previous fetch found. load..."
  {i,data} = JSON.parse fs.read-file-sync "data/#board/post-list.json"
  console.log ">>>", i
  index = i
fetch-list index + 1
