require! <[fs prelude-ls]>

if process.argv.length < 3 =>
  console.log "usage: lsc id-stat.ls [board-name]"
  console.log "example: lsc id-stat.ls food"
  process.exit!
board = process.argv.2
files = fs.readdir-sync "data/#board/post"
hash = {}
relate = {}

[data, suspect] = JSON.parse(fs.read-file-sync "data/#board/id-stat.json" .to-string!)
max0 = 0
id0 = null
max2 = 0
id2 = null
feiwen-count = 0
feiwen-id = null
post-count = 0
post-id = null

mincount = 0
count = 0
for k,v of data
  count++
  if (count % 100)==0 => console.log "#count nicks parsed"
  #console.log k, v
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
console.log "可疑文章及推文"

suspect-count = {}
for item in suspect
  console.log "#{item.2}: #{item.0}, '#{item.1}'"
  if !suspect-count[item.0] => suspect-count[item.0] = 0
  if !relate[item.0] => relate[item.0] = []
  if item.2 < 0 =>
    suspect-count[item.0]++
    relate[item.0].push [item.1, item.2, item.0, item.4]
  if item.3 =>
    console.log "可疑推文者"
    console.log("  --> ", item.3.join " ")
    for id in item.3
      if !suspect-count[id] => suspect-count[id] = 0
      if !relate[id] => relate[id] = []
      suspect-count[id]++
      relate[id].push [item.1, item.2, item.0, item.4]
suspect-id = [[k,v] for k,v of suspect-count]sort (a,b) -> a.1 - b.1
for item in suspect-id
  console.log item.0, item.1
  if item.1 > 100 => console.log ["#{v.1} #{v.0}" for v in relate[item.0]].join "\n"

fs.write-file-sync "data/#board/suspect.json", JSON.stringify {suspect: suspect-id, relate: relate}
