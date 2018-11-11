# PHP Spreadsheetの速度を確認してみた

## Description

dockerがないと使えない.

## Usage

```sh
$ time bash php7/chart.php
```

## Results

簡単なchartの画像を差し込んだexcel作成で1sぐらい.


```sh
$ time bash time.sh

real	0m10.481s
user	0m0.570s
sys	0m0.830s
```
