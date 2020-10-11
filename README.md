## setup

```
$ bundle install
$ bundle exec pod install
```

## 問題
DiffableDataSource を使った画面で、編集モードで並び替え後、クラッシュする。
元の実装は、MVVMで `tableView(_: moveRowAt: to:)` のコール後、自動的に `dataSource.apply` が呼ばれる。
この検証ソースでは、それを模倣するために、編集モードを抜けるときに `dataSource.apply` を呼ぶ。
この時、移動した結果は反映されたデータを用いる。

## 原因
確証はないが、DiffableDataSourceのデフォルト実装に問題がある。
`tableView(_: moveRowAt: to:)` が呼ばれた時に、`snapshot` が更新されておらず、その後の `dataSource.apply` の際の `currentSnapshot` が移動を反映していないものになっている。
表示上は、移動が済んでいるのに、その上同じ移動を再現しようとして、状態の不整合が起きているようだ。

