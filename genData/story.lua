stories={

storyLoc1={
"Long ago..."
,"So long ago that everyone forgot..."
, function() bgChange("dragonBalls1") end
,"7 magical spheres came to Earth."
,"When gathered, these sacred orbs call forth the Eternal Dragon!"
,"The Dragon will then grant a single wish!"
,"Today, everyone has forgotten this legend."
,"Including the boy who owns one of these balls as a keepsake from his "
,"late grandfather."
, function() portChange("dbGokuSmile", "center") end
,"The boy's name is Son Goku."
,"Despite his size, Goku has remarkable strength and skill, making him exceptional!"
,"Not to mention his tail!"
, function() bgChange("dbGohanHouse") end
,"Ever since his grandfather passed away, Goku has lived alone deep in the woods."
,"But he is more than capable of taking care of himself."
,"This will come in handy as he is about to set out on an adventure that will change his life!"
, function() dTag("left", "Goku") end
,"Okay! Grandpa, I'm headed out to get some food. I'll be back soon."
,"Don't go anywhere, okay?"
, function() dTag("clear") end
, function() portChange("clear") end
,"Goku sets out to find food like he normally does this time of day."
, function() gameModeChange(GameMode.MAP,maps.mapNumberT) end
,"EOF"
},

storyLoc1A={
 function() bgChange("dbRiver") end
,"He approaches the river down in the lowlands and..."
, function() portChange("dbGokuExcite", "left") end
, function() dTag("left", "Goku") end
,"Aha! The fish are as big as ever!"
,"Hmmm...I bet I can catch that one!"
, function() dTag("right", "Fish") end
, function() portChange("dbFish", "right") end
,"Oh please, not me!"
, function() portChange("clear", "right") end
, function() portChange("dbGokuNeut", "left") end
, function() dTag("left", "Goku") end
,"Oh okay..."
, function() dTag("right", "Big Fish") end
, function() portChange("dbFishAlive", "right") end
,"Small Fry! Get lost before I gobble you up!"
, function() dTag("left", "Goku") end
,"You talkin' to me?"
, function() dTag("right", "Big Fish") end
,"You bet! I'll swallow you whole, little boy!"
, function() dTag("left", "Goku") end
, function() portChange("dbGokuSmirk", "left") end
,"Ha! A fight? Let's go!"
,2 -- menu
},

storyLoc2={}

}