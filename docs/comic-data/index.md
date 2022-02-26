---
layout: default
nav_order: 3
has_children: true
---

# Comic Data

The `comicData` table defines your entire comic. A Panels comic is broken down into [Sequences](sequences), [Panels](panels), and [Layers](layers). Your `comicData` table can be defined as one large table in a single file, or it can be assembled from multiple smaller tables. Putting each sequence in its own file can help keep things organized.

The top level of the `comicData` table is a list of the sequences in your app. Each sequence is represented by its own table.
No other information should appear at the top level of your table.

```lua
comicData = {
    {
        -- data for sequence 1
    }, {
        -- data for sequence 2
    }, {
        -- data for sequence 3
    }
}
```
