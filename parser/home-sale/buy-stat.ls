require! <[fs]>

files = fs.readdir-sync "../../data/home-sale/post"
#files = <[M.1396271218.A.249]>
#files = <[M.1300870386.A.3E1]>

tag = <[房屋地點 房屋屋齡 房屋類型 所在樓層 房屋坪數 房屋格局 房屋座向
  屋前巷(路)寬 購屋預算 有無陽台 有無停車位 交通 附帶條件說明 聯絡資訊]>

edit = "※ 編輯"
hash = []
for file in files
  filter = {name: file}
  data = fs.read-file-sync "../../data/home-sale/post/#file" .to-string!
  ret = / 標題  \[買屋\]/exec data
  if !ret => continue
  lines = data.split \\n
  cur = null
  for line in lines =>
    if !filter.time => 
      if /^ 時間  (.+)/.exec line => 
        filter.time = new Date(that.1)get-time!
    line = line.trim!
    if line == "--" => break
    if line.index-of(edit) == 0 => break
    if !line => continue
    ret =/^\d+[.、]\s*(\S+?)\s*[：:](.*)/exec line
    if ret =>
      if ret.1 not in tag => continue
      cur = ret.1
      index = tag.index-of cur
      filter[cur] = ret.2
    else if cur => 
      filter[cur] += line
  hash.push filter
output = JSON.stringify hash
fs.write-file-sync \stat.buy.json, output

