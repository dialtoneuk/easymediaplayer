# Notable Issues

Before moving fully to githubs issue resolution platform, theres are some of the bugs I'm coming across as of now and what I still need to fix.

## Voting

Can still start a voteban even if your the only one in the server also appears no ply object is sent

```
[easyyoutubeplayer] addons/easyyoutubeplayer/lua/lyds/server/sv_media_blacklist.lua:33: attempt to index local 'ply' (a nil value)
  1. AddToBlacklist - addons/easyyoutubeplayer/lua/lyds/server/sv_media_blacklist.lua:33
   2. OnSuccess - addons/easyyoutubeplayer/lua/lyds/server/sv_media_voting.lua:56
    3. ExecuteVote - addons/easyyoutubeplayer/lua/lyds/server/sv_media_voting.lua:267
     4. StartVote - addons/easyyoutubeplayer/lua/lyds/server/sv_media_voting.lua:252
      5. unknown - addons/easyyoutubeplayer/lua/lyds/server/sv.lua:298
       6. unknown - lua/includes/modules/concommand.lua:54
```
