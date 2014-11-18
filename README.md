ptt-crawler
===========

crawl ptt articles from its website

usage:

* install:

    `npm install`

* scraping certain ptt board:

    `lsc crawler.ls <board-name>`

All posts will be downloaded into data/<board-name>/post/ folder. There will also be a data/<board-name>/post-list.json to kepp track of your download history, so you can interrupt your download at any time and resume later.


* categorize authors by title:

    `lsc cat.ls <board-name>`



working flow: 

	First fetchs post list and writes to file per 30 lists. After finishes list fetching, fetches post and writes to file immediately.

food.ls: example for fetching articles for article generation

home-sale.ls: example for categorizing purpose of articles

id-stat.ls: analyze users stand point. output to data/<board-name>/id-stat.json

id-stat-show.ls: show users statistics, generate suspect.json.

feature:
	
	Support continuious fetching.

issue:
	Current function may not retry after connection failed.
