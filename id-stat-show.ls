require! <[fs prelude-ls]>

if process.argv.length < 3 =>
  console.log "usage: lsc id-stat.ls [board-name]"
  console.log "example: lsc id-stat.ls food"
  process.exit!
board = process.argv.2
files = fs.readdir-sync "data/#board/post"
hash = {}

data = JSON.parse(fs.read-file-sync "data/#board/id-stat.json" .to-string!)
max0 = 0
id0 = null
max2 = 0
id2 = null
feiwen-count = 0
feiwen-id = null
post-count = 0
post-id = null

mincount = 0
for k,v of data
  console.log k, v
  if v.push =>
    if max0 < v.push.0 => [max0,id0] := [v.push.0,k]
    if max2 < v.push.2 => [max2,id2] := [v.push.2,k]
    mincount += v.push.0
  if v.post =>
    len = v.post.length
    if len > post-count =>
      post-count = len
      post-id = k
    len = v.post.filter(-> it.0 < 0)length
    if len > feiwen-count =>
      feiwen-count = len
      feiwen-id = k
console.log "噓噓之王: #id0, 共噓了 #max0 次"
console.log "推推之王: #id2, 共推了 #max2 次"
console.log "總共有 #mincount 個噓"
console.log "費文王: #feiwen-id 被噓了 #feiwen-count 篇文章"
console.log "文章王: #post-id 發表了 #post-count 篇文章"
