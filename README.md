ptt-crawler
===========
Crawl ptt articles from its website

Usage
===
* install:

    `npm install`

* scraping certain ptt board:

    `lsc crawler.ls <board-name>`

All posts will be downloaded into data/<board-name>/post/ folder. There will also be a data/<board-name>/post-list.json to kepp track of your download history, so you can interrupt your download at any time and resume later.


* categorize authors by title:

    `lsc cat.ls <board-name>`

Working Flow 
===
1. First fetchs post list and writes to file per 30 lists.
2. After finishes list fetching, fetches post and writes to file immediately.

Example
===
* food.ls: example for fetching articles for article generation
* home-sale.ls: example for categorizing purpose of articles

Analysis
===
* id-stat.ls: analyze users stand point. output to data/<board-name>/id-stat.json
* id-stat-show.ls: show users statistics, generate suspect.json.

Feature
===
Support continuious fetching.

Issue
===
Current function may not retry after connection failed.
