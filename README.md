ptt-crawler
===========

crawl ptt articles from its website

usage:

scraping certain ptt board:

    lsc crawler.ls <board-name>

All posts will be downloaded into data/<board-name>/post/ folder. There will also be a data/<board-name>/post-list.json to kepp track of your download history, so you can interrupt your download at any time and resume later.


categorize authors by title:

    lsc cat.ls <board-name>

food.ls: example for fetching articles for article generation
home-sale.ls: example for categorizing purpose of articles
id-stat.ls: analyze users stand point. output to data/<board-name>/id-stat.json
id-stat-show.ls: show users statistics, generate suspect.json.

LICENSE
============

all sources are licensed under [CC-BY-4.0 license](https://creativecommons.org/licenses/by/4.0/).
