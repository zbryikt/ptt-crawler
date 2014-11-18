require! <[fs prelude-ls ]>

if process.argv.length < 3 =>
  console.log "usage: lsc id-stat.ls [board-name]"
  console.log "example: lsc id-stat.ls food"
  process.exit!
board = process.argv.2

try
  files = fs.readdir-sync "../data/#board/post"
  if files.length == 0
     console.log "There is no post in this board or fetching failed."
     process.exit!
catch
  console.log "Please fetching post of this board first."
  process.exit!

hash = {}
suspect = []

id-count = (name, post, push, title) ->
  if !isNaN(post) => hash.{}[name].[]post.push [post, title]
  if !isNaN(push) => 
    if not hash.{}[name]push => hash[name]push = [0,0,0]
    hash[name]push[push + 1]++

rule = 
  push: /^\s*([推噓→])\s+([a-zA-Z0-9]+)\s*:/

pushmap = "推→噓"
count = 0
for file in files
  count++
  if (count % 100) == 0 => console.log "#count files parsed."
  fkey = file
  file = "../data/#board/post/#file"
  #if not /\.html$/.exec file => continue
  lines = fs.read-file-sync file .to-string!split \\n
  author = /^\s*作者\s+(\S+)/.exec lines.1
  title = /^\s*標題\s+(.+)/.exec lines.3
  if not (author and title) => continue
  # now we have author and title
  [author,title] = [author.1,title.1]
  push = false
  score = 0
  booer = []
  for line in lines
    if !push =>
      if /^--\s*$/.exec line => push = true
      continue
    ret = rule.push.exec line
    if !ret => continue
    [type, id] = [ 1 - pushmap.index-of(ret.1), ret.2]
    id-count id, undefined, type
    if type < 0 => booer.push id
    score += type
  id-count author, score, undefined, title
  if score < -25 or score > 25 and booer.length > 0 => 
    if score < -25 => booer = []
    suspect.push [author, title, score, booer, fkey]
  #if score < -200 =>
  #  console.log author
  #  process.exit -1
fs.write-file-sync "../data/#board/id-stat.json", JSON.stringify([hash, suspect])
