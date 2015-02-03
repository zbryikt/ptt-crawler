#!/usr/bin/env lsc
require! <[fs request]>

if process.argv.length < 3 =>
  console.log "usage: lsc crawler.ls [board-name] "
  console.log "example: lsc crawler.ls food"
  process.exit!
board = process.argv.2

list-count = 0
is-sync = false
post-list = {page: 0, post: {}}
post-queue = []
request = request.defaults jar: true
jar = request.jar!
cookie = request.cookie "over18=1"

post-done = ->
  console.log "fetch post done. "

fetch-article = (idx) ->
  while true =>
    key = post-queue[idx]
    if !key => break
    if not fs.exists-sync "data/#board/post/#{key.0}" => break
    idx++
  if idx >= post-queue.length => return post-done!
  url = "http://www.ptt.cc#{key.1}"
  jar.set-cookie cookie, url
  request {url,jar}, (e,r,b) ->
    if b => 
      c = b.index-of '<div id="main-container">'
      if c => b = b.substring c
      b = b.replace /(<\/?div[^>]*>\s*)+/g, \\n
      b = b.replace /<\/div>/g, \\n
      b = b.replace /<[^>]+>/g, " "
      console.log "post", idx, key.0, (b or "")length, e, r.status-code
      if e or r.status-code != 200 =>
        return set-timeout (-> fetch-article (if r.status-code==404 => idx + 1 else idx)), 2000
      fs.write-file-sync "data/#board/post/#{key.0}", b
    else idx := idx - 1
    return if idx == post-queue.length - 1 => post-done! else set-timeout (-> fetch-article idx + 1), 11

post-list-done = (i) -> 
  fs.write-file-sync "data/#board/post-list.json", JSON.stringify post-list
  post-queue := [[k, "/bbs/#board/#k.html"] for k of post-list.post]
  console.log "fetch post list done, total #{post-queue.length} posts."
  console.log "fetching posts..."
  fetch-article 0

fetch-list = (page) ->
  if page == 0 => 
    post-list.page = 0
    return post-list-done!
  url = "http://www.ptt.cc/bbs/#board/index#page.html"
  jar.set-cookie cookie, url
  request {url, jar}, (e,r,b) ->
    console.log "list", page, e, (if r => r.status-code else "no response")
    if e or !r or r.status-code != 200 => 
      set-timeout (-> fetch-list page), 2000
    lines = b.replace /(\\t)+/g .split \\n
    for line in lines
      ret1 = /a href="([^"]+)">(.+)<\/a>\s*$/.exec line
      ret2 = /<div class="author">([^<]+)</.exec line
      if not (ret1 or ret2) => continue
      if ret1 => [href,title] = ret1[1,2]
      if ret2 => author = ret2.1
      key = if /\/([^/]+)\.html$/.exec href => that.1 else null
      if author and title and key =>
        if (key of post-list.post) and is-sync => return post-list-done!
        post-list.post[key] = [author, title]
        [author, title, href, key] = [null,null,null,null]
    post-list.page = page
    if (page % 30) == 0 =>
      console.log "(write current result: #page records)"
      fs.write-file-sync "data/#board/post-list.json", JSON.stringify post-list
    set-timeout (-> fetch-list page - 1), 100 + parse-int(Math.random!*300)

fetch-index = ->
  url = "http://www.ptt.cc/bbs/#board/index.html"
  jar.set-cookie cookie, url
  console.log "analyzing how many lists to fetch..."
  request {url, jar}, (e,r,b) ->
    #ret = /\s+href="index(\d+)\.html">\&lsaquo; 上頁<\/a>/.exec b.replace /[\r\n]/g, ""
    ret = /\s+href=".+\/index(\d+)\.html">&lsaquo; 上頁<\/a>/.exec b.replace /[\r\n]/g, ""
    if !ret => return console.log "cannot find the last list page index. abort."
    list-count := ret.1 
    console.log "total #list-count list pages. "
    set-timeout (-> fetch-list list-count), 100


if !fs.exists-sync("data") => fs.mkdir-sync "data"
if !fs.exists-sync("data/#board") => fs.mkdir-sync "data/#board"
if !fs.exists-sync("data/#board/post") => fs.mkdir-sync "data/#board/post"

console.log "fetching board '#board'..."

if fs.exists-sync("data/#board/post-list.json") =>
  console.log "previous fetch found. load..."
  post-list = JSON.parse fs.read-file-sync "data/#board/post-list.json"
  if post-list.page != 0 => fetch-list post-list.page
  else 
    console.log "previous fetch complete. only syncing latest update..."
    is-sync = true
    fetch-index!
else
  fetch-index!
