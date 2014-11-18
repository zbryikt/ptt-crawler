require! <[fs]>

hash = {}
format = ->
  i = 1
  offset = 1
  escape = " ☆！？【】()．#,.;：；，。・、◎◇◆「」║▌╰╯║║▌╭╮═˙└─┴┘"
  esc = new RegExp "\s+|[#escape]"
  total = 0
  while true
    if not fs.exists-sync("post/#i.html") => 
      console.log i
      break
    b = fs.read-file-sync "post/#i.html" .to-string!
    b = b.replace /&#34/g, ""
    b = b.replace /[*-]+/g," "
    c = b.last-index-of \\n--\s*\n
    if c > 0 => b = b.substring(0, c)
    b = b.split \\n 
    #console.log b.3
    if not /鼎王/.exec(b.3) =>
      #if not /^\s+標題\s+.+鼎王/.exec(b.3) =>
      i+=offset
      continue
    #console.log total++
    b = b.splice 5
    b = b.filter -> it.trim! != "" and not /^  ?[:※]/.exec it
    b = b.filter -> not /^ [推→]/.exec it
    b = b.join " " .split esc .filter -> 
      it and not /^[ a-zA-Z0-9_+=*&^#~.;:,/?"'|-]+$/.exec(it) and not /^ ?From:/.exec(it)
    b = b.map -> it.trim!replace /\s+/g, " "
    b = b.filter -> it and it.length > 3
    j = 0
    for c in b =>
      key = parseInt((j / b.length) * 100 )
      hash.[][key].push c
      j++
    i+=offset

if not fs.exists-sync(\sentence-stat.json) =>
  format!
  fs.write-file-sync \sentence-stat.json, JSON.stringify hash
else
  hash = JSON.parse fs.read-file-sync \sentence-stat.json

sentence = []
count = 1
comma = <[， ， ； 。 。 。]>
for i from 6 to 99
  if !hash[i] => continue
  b = hash[i]
  idx = parseInt( Math.random! * b.length )
  sentence.push b[idx]
  cidx = parseInt( Math.random! * count )
  if cidx > 3 => count = 1 else count++
  if i == 99 => cidx = comma.length - 1
  sentence.push comma[cidx]
console.log sentence.join ""
