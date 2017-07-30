# Contributing

Please make a pull request on a new branch. Branches should be named in the manner of `development/*`. Please adorn commit messages with [gitmoji](https://gitmoji.carloscuesta.me/).

`include`s must be in alphabetical order, unless they conflict. `AddCSLuaFile`s must be in alphabetical order.

All strings that the player sees must be internationalized (see [I18](#i18)).

## Mapping

Use the `coi.fgd` provided in this repository. In addition, the `.vmf` for `coi_test` is provided in `content/maps` (needs CS:S content).

### coi_truck

Place these where you want spawnpoints/loot points to be. Players spawn at the back of these. The gamemode will only make enough teams as there are trucks, so keep in mind the desired game size when placing these.

### coi_money

Place these in the vault. You can put any number of these in, as long as there's at least one.

### coi_copspawner

Place where you want cops to spawn in. There should be a decent peppering of these throughout the map.

## I18

If you'd like to translate the gamemode, you are welcome! Look at `gamemode/i18/en.lua` as a starting point. Whatever language the client has set (`en`, `fr` etc.) will be what's displayed, according to the Garry's Mod main menu language selection.
