pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

p = {
	x=64,
	y=64,
	speed=8,
	sprite=0,
	tag=1,
	box={x1=0,y1=0,x2=7,y2=7},
 anim=0
}

ctime={
	m=0,
	s=0,
	ms=0
}


-- variables intro --
txtintro = {"year 18. an extreme cold has  ","covered vallis bona land. but","it wasn't a coincidence:scouls","have invaded the country. on  ","their frozen planet, it was im","possible for them to eat somet","hing else than ice.humanity is"," facing a plight: giving their"," best meals or die..."}
txtintrotmp = sub(txtintro[1],1,1)
cptintro = 1
yintro = 30
cptline = 0
nbloop = 0
timeintro = 0

fin_y=120

--variables texte fin --
txtfin = {"well done!you've finally found","the best vallis bona's dish : ","the humburger! scouls are now ","satiated and they are leaving ","the earth alone. you have just"," saved humanity!"};
txtfintmp = sub(txtfin[1],1,1)
cptfin = 1
yfin = 50
cptline_fin = 0
nbloop_fin = 0
timefin = 0



scr={}
s=0
tabsprite={{16,18,32,34},{20,22,36,38},{24,26,40,42},{28,30,44,46}}
monstersprite={48,50,52}
chrono=0
level=1
actors={}
xmap=128
ymap=64
arret=true
direction=""
particles={}
explosions={}
spawn={
{9,10},
{37,1},
{60,14},
{70,14},
{126,8},
{14,24},
{37,38},
{48,38},
{82,37},
{126,31},
{24,62},
{60,62},
{79,56},
{126,62}
}
spawnmonster={{{7,8,"v"}}
,{{30,4,"v"},{27,10,"h"}}
,{{56,4,"v"},{59,10,"h"}}
,{{72,7,"h"},{78,11,"v"},{71,3,"v"},{74,2,"h"}}
,{{99,1,"v"},{100,14,"v"}}
,{{6,32,"v"},{7,36,"h"}}
,{{32,28,"h"}}
,{{54,33,"h"},{56,26,"v"},{50,33,"v"}}
,{{70,36,"v"},{82,32,"v"},{70,25,"h"}}
,{{33,50,"h"},{33,56,"h"}}
,{{}}
,{{}}
,{{72,58,"h"},{81,57,"v"}}
,{{103,51,"h"},{109,60,"h"},{111,60,"v"}}
}
-- { tous les monstres du jeu { tous les monstres du level { 1 monstre

teleporteur={{4,11},{},{},{},{},{11,26},{31,31},{54,31},{77,31},{118,26},{},{56,62},{75,53},{109,55}}

------ fonctions initialisations ------

function _init()
  cartdata("v0")
		music(3)
  if(dget("unlock")==nil) dset("unlock",1)
  update_shake()
  _update = intro_update
		_draw = intro_draw
		cls()
end

function init_monster(level)
  local tab=spawnmonster[level]
  for monster in all(tab) do
      if monster[1]!=nil and monster[2]!=nil and monster[3] then
        create_actor(monster[1]*8,monster[2]*8,monster[3],2)
      end
  end
end

---------------------------------------------


------ fonctions update ------
-- appelées 30 fois par sec :

function intro_update()
	timeintro += 1
	intro(timeintro)
end

function menu_update()
		if level==15 then
			music(2)
   txtfintmp = sub(txtfin[1],1,1)
   cptfin = 1
   yfin = 50
   cptline_fin = 0
   nbloop_fin = 0
   timefin = 0
			_update=end_update
			_draw=draw_end_txt
		end
		select_level()
  select_player()
	if (btn(5)) then
    _update=game_update
    _draw=game_draw
    music(-1)
    init_monster(level)
    p.x=spawn[level][1]*8
    p.y=spawn[level][2]*8
	end
end

function game_end()
	level=1
	if (btnp(4)) then
		go_menu()
	end
end

function game_update()
  time_manager()
  move_actor()
  deplacement()
  touch_flag()
  anim_dir(direction)
  animation("")
  if(arret!=true) then make_particles(5) end
end

function end_update()
	if(btnp(4)) then
		_draw = draw_end
		_update = game_end
	end
	timefin += 1
	if(timefin > 130) then
		if(timefin <= 140) then
			music(4)
		end
		txtend(timefin)
	end
end

-- autres :

function update_shake()
	scr={}
	scr.x=p.x
	scr.y=p.y
	scr.shake=0
	scr.intensity=4
end

---------------------------------------------

------ fonctions draw ------
-- appelées 30 fois par sec :

function intro_draw()
end --fonction qui ne fait rien, pour garder un fond noir derrière

function menu_draw()
 cls()
 map(0,48,0,0,16,16)
 camera(0,0)
 print("press x to start",25,65,0)
 print("⬆️",108,64,0)
 print("⬅️⬇️➡️", 100,70,0)
 spr(p.sprite,44,35)
  if(dget(level)!=nil) then
    print("level "..level,35,50,0)
    print("best time : "..dget(level),25,57,0)
  else print("level "..level,10,18,0)
  end
  print("⬅️     ➡️",30,35)
end

function game_draw()
 cls()
 camera_pos()
 map(0,0,0,0,xmap,ymap)
 spr(p.sprite,p.x,p.y)
 draw_actor()
 draw_particles()
 draw_explosions()
 print(ctime.s+ctime.ms,p.x-64<0 and 0 or p.x-64,p.y-64<0 and 0 or p.y-64,7)
end

function draw_end()
	fin_y-=1/5
	if fin_y<-105 then fin_y=120 end
		cls()
		print("thanks for playing",30,fin_y,7)
		print("by",60,fin_y+20,7)
		print("maeva lecavelier",35,fin_y+60,7)
		print("loic bertolotto",35,fin_y+80,7)
		print("clement poueyto",35,fin_y+40,7)
		print("press c to continue",30,fin_y+100,7)
end

function draw_end_txt()--fonction qui ne fait rien, pour garder un fond noir derrière
map(0,0,0,0,0,0)
end

-- les autres  :

function draw_actor()
 for a in all(actors) do
  spr(a.sprite,a.x,a.y)
 end
end

function draw_particles()
    for part in all(particles) do
        pset(part.x,part.y,part.col)
        part.x+=part.dx
        part.y+=part.dy
        part.frame+=1
        if (part.frame>part.framemax) then
            del(particles,part)
        end
    end
end

function draw_explosions()
    for e in all(explosions) do
        circfill(e.x,e.y,e.r,e.c)
        e.r-=1
        if(e.r<5) e.c =9
        if(e.r<3) e.c=8
        if(e.r<=0) del(explosions,e)
    end
end

function make_particles(nb)
    while (nb>0) do
        part={}
        part.x=p.x+4
        part.y=p.y+4
        part.col= flr(rnd(16))
        part.dx= (rnd(2)-1)*0.7
        part.dy= (rnd(2)-1)*0.7
        part.frame=0
        part.framemax=10
        add(particles,part)
        nb -=1
    end
end

function make_explosion(x,y,nb)
    while (nb>0) do
        explo={}
        explo.x=x
        explo.y=y
        explo.r=6
        explo.c=10
        add(explosions,explo)
        sfx(0)
        nb-=1
    end
end


-- l'animation :

function anim_dir(direction)
  if direction=="g" then p.sprite=tabsprite[s][1] end
  if direction=="d" then p.sprite=tabsprite[s][3] end
  if direction=="h" then p.sprite=tabsprite[s][2] end
  if direction=="b" then p.sprite=tabsprite[s][4] end
  p.anim=p.sprite
end

function animation(debug)
  if ctime.s%2==0 and p.sprite==p.anim and direction!=debug  then
    p.sprite+=1
  elseif ctime.s%2==0 and p.sprite!=p.anim and direction !=debug then
    p.sprite=p.anim
  end
end


---------------------------------------------

------ menu ------

function intro(timeintro)
 print("press c to skip",60,120)
	if(timeintro % 3 == 0) and (nbloop < 261) then
		nbloop += 1
		numsentence = get_sentence(nbloop)
		print(txtintrotmp, 0, yintro, 7)
		if(nbloop % 30 == 0) then --faire un retour à la ligne
			yintro += 7
		end
		txtintrotmp = sub(txtintro[numsentence], 1, nbloop%30+1) -- récupère 1 à 1 les 30 premiers caractères (nbloop%30)
		sfx(4)
	end
	if(btnp(4)) then --on affiche le menu quand le joueur appuie sur 'c'
		go_menu()
	end
end

function go_menu()
  _update=menu_update
  _draw= menu_draw
  actors={}
  music(0)
end

function select_player()
  if(btnp(0)) then
    s+=1
  elseif(btnp(1)) then
    s-=1
  end
  if(s>4) then s=1
  elseif s<1 then s=4
  end
  p.sprite=tabsprite[s][4]
  p.anim=p.sprite
end

function select_level()
	if (btnp(2)) then
    if level < 14 and dget("unlock")>level then
		  level+=1
    else sfx(3)
    end
  end
	if (btnp(3) and level>1) then
		level-=1
	end
end

function unlocklevel()
  if dget("unlock")!=0 then
    if dget("unlock")==level then
    dset("unlock",level+1)
    end
  else dset("unlock",2)
  end

end

function update_score()
  if(ctime.s+ctime.ms<dget(level)) then
    dset(level,ctime.s+ctime.ms)
  end
  if (dget(level)==0) then
    dset(level,ctime.s+ctime.ms)
  end
end

------- texte fin -----

function txtend(timefin)
 print("press c to skip",60,120)
	if(timefin % 3 == 0) and (nbloop_fin < 166) then
		nbloop_fin += 1
		numsentence = get_sentence(nbloop_fin)
		print(txtfintmp, 0, yfin, 7)
		if(nbloop_fin % 30 == 0) then --faire un retour à la ligne
			yfin += 7
		end
		txtfintmp = sub(txtfin[numsentence], 1, nbloop_fin%30+1) -- récupère 1 à 1 les 30 premiers caractères (nbloop%30)
		sfx(4)
	end
end -- même fonctionnement que intro
---------------------------------------------

------ game ------

-- deplacement :

function move_actor()
  for a in all(actors) do
  collisions()
    if a.tag=="h" then
        a.x+=(a.coefdir)
        if (hitwall(a.x,a.y,0)) then
        a.coefdir*=(-1)
        end
    end
    if a.tag=="v" then
        a.y+=(a.coefdir)
        if (hitwall(a.x,a.y,0)) then
        a.coefdir*=(-1)
        end
    end
    monster_anim_dir(a)
  end
end

function move(direction)
  -- this function moves the
  -- character

  -- first we remember the
  -- position of the character
  -- on the last frame
  local old_x=p.x
  local old_y=p.y

  -- check if player wants to
  -- move the player left/right
  if direction=="g" then
   p.x-=p.speed
  end
  if direction=="d" then
   p.x+=p.speed
  end

  -- check if moving the mouse
  -- will make her run into a
  -- wall.
  if hitwall(p.x,p.y,0) then
   -- if so, undo the movement
   arret=true
   p.x=old_x
  end

  -- now the same with up/down
  -- check if player wants to
  -- move the player up/down
  if direction=="b" then p.y+=p.speed end
  if direction=="h" then p.y-=p.speed end

  -- check if moving the player
  -- will make her run into a
  -- wall.
  if hitwall(p.x,p.y,0) then
   -- if so, undo the movement
   arret=true
   p.y=old_y
  end
  arrow()
  bounce_wall()
  teleporter()
end

function deplacement()

 if(arret==true) then
  if (btn(0) and arret==true) then direction="g" move(direction)
    arret=false end
  if (btn(1) and arret ==true) then direction="d" move(direction)
    arret=false end
  if (btn(2) and arret ==true) then direction="h" move(direction)
    arret=false end
  if (btn(3) and arret ==true) then direction="b" move(direction)
    arret=false end
 else
  if direction=="g" then move(direction) end
  if direction=="d" then move(direction) end
  if direction=="h" then move(direction) end
  if direction=="b" then move(direction) end
 end
end

-- interaction object/player :

function collisions()
  for a in all(actors) do
    if check_coll(a,p)==true then
        make_explosion(p.x,p.y,2)
      arret=true
      screenshake(10)
      p.x=spawn[level][1]*8
      p.y=spawn[level][2]*8
    end
  end
end

function hitwall(_x,_y,flag)

  if (checkspot(_x  ,_y  ,flag)) return true
  if (checkspot(_x+7,_y  ,flag)) return true
  if (checkspot(_x  ,_y+7,flag)) return true
  if (checkspot(_x+7,_y+7,flag)) return true

  return false
 end

 function monster_anim_dir(a)
  if a.tag=="h" and a.coefdir>0 then
    a.sprite=a.fi
  elseif a.tag=="h" and a.coefdir<0 then
    a.sprite=a.fi+1
  end
 end

function check_coll(a,p)
	  local box_a = get_box(a)
	  local box_p = get_box(p)
	  if (box_a.x1> box_p.x2 or box_a.y1 > box_p.y2 or box_p.x1>box_a.x2 or box_p.y1 >box_a.y2) then
	    return false
	  end
	  return true
	end

-- camera :

function camera_pos()
  if(scr.shake>0) then
    scr.x=(rnd(2)-1)*scr.intensity
    scr.y=(rnd(2)-1)*scr.intensity
    scr.shake-=1
    camera(p.x+scr.x-64<0 and 0 or p.x+scr.x-64,p.y+scr.y-64<0 and 0 or scr.y+p.y-64)
  else
    camera(p.x-64<0 and 0 or p.x-64,p.y-64<0 and 0 or p.y-64)
		end
end

function teleporter()
    if checkspot(p.x,p.y,2) then
        p.x=teleporteur[level][1]*8
        sfx(2)
        p.y=teleporteur[level][2]*8
    end
end

function arrow()
  if hitwall(p.x,p.y,4) then direction ="g" sfx(6)
  elseif hitwall(p.x,p.y,5) then direction ="h" sfx(6)
  elseif hitwall(p.x,p.y,6) then direction ="d" sfx(6)
  elseif hitwall(p.x,p.y,7) then direction ="b" sfx(6)
  end
end

function touch_flag()
  if checkspot(p.x,p.y,1)==true then
    arret=true
    go_menu()
    update_score()
    reset_timer()
    unlocklevel()
    direction=""
    level+=1
  end
end

-- ennemis :

function create_actor(x,y,tag,sprite)
	local actor={}
	actor.x=x
	actor.y=y
	actor.tag=tag
	actor.sprite=sprite
  actor.coefdir=1
	actor.box={x1=0,y1=0,x2=7,y2=7}
  actor.sprite=monstersprite[flr(rnd(3))+1]
  actor.fi=actor.sprite
	add(actors,actor)
end

function bounce_wall()
  if hitwall(p.x,p.y,3) then
    if direction=="g" then direction="d"
    elseif direction=="d" then direction="g"
    elseif direction=="h" then direction="b"
    elseif direction=="b" then direction="h"
    end
  end
end

-- auxiliaires :

function get_box(a)
  local box= {}
  box.x1 = a.x+a.box.x1
  box.y1 = a.y+a.box.y1
  box.x2 = a.x+a.box.x2
  box.y2 = a.y+a.box.y2
  return box
end

function screenshake(nb)
  scr.shake=nb
end

function checkspot(_x,_y,_flag)
  local tilex=_x/8
  local tiley=_y/8
  -- then we get the tile number
  -- at that map position
  local tile=mget(tilex,tiley)
  -- and then we return its
  -- flag
  return fget(tile,_flag)
end

-- intro : permet de savoir quelle phrase il faut afficher à l'intro
function get_sentence(nbloop)
	if(nbloop < 30) then
		return 1
	end
	if(nbloop < 60) then
		return 2
	end
	if(nbloop < 90) then
		return 3
	end
	if(nbloop < 120) then
		return 4
	end
	if(nbloop < 150) then
		return 5
	end
	if(nbloop < 180) then
		return 6
	end
	if(nbloop < 210) then
		return 7
	end
	if(nbloop < 240) then
		return 8
	end
	if(nbloop < 270) then
		return 9
	end
  if(nbloop <=300) then
    return 10
  end
end


-- chronometre :

function time_manager()
	ctime.ms += 1/30
	if (ctime.ms >= 1) then
		ctime.ms=0
		ctime.s+=1
	end
end

function reset_timer()
	ctime.s=0
	ctime.m=0
	ctime.ms=0
end

---------------------------------------------





__gfx__
000000000000000000000000c11cc11cc889988c000cc000000cc000000000000000000000000000bb333333344f4f430bbbbb00dddd3ddd555995550ffffff0
00000000000000000000000011cccc118899998800cccc00000cc00000000c0000c0000000000000333bb353444444440b333b00dd3d3d3d55999955ffffffff
0000000000000000000000001cc66cc1899aa9980cccccc0000cc00000000cc00cc000000000000035533bb344f444f40bb33b00dd83338d5999999544444444
0000000000000000000000001c6666c189aaaa98000cc000000cc000cccccccccccccccc00000000b3333b33f444f444bbb3bbbbd83383389999999999999999
0000000000000000000000001c6666c189aaaa98000cc000000cc000cccccccccccccccc0000000053333b3333333333b3bbb33bd88888879999999988888888
0000000000000000000000001cc66cc1899aa998000cc0000cccccc000000cc00cc000000000000035bb3b334444f444b33b333bd888888859999995bbbbbbbb
00000000000000000000000011cccc1188999988000cc00000cccc0000000c0000c000000000000035333b3b4f44444fbb3b33bbd888888855999955ffffffff
000000000000000000000000c11cc11cc889988c000cc000000cc00000000000000000000000000033335333344f44430bbbbbb0dd88888d555995550ffffff0
00999900009999900009900000999900004444000044444000044000004444000044440000444400000440000044440000666600006666000006600000666600
00ff999000ff9999009999000099990000ff444000ff4444004444000044440000ff440000ff4400004444000044440000ff660000ff66000066660000666600
00f3f99900f3f999009999000999999000f1f44400f1f444004444000444444000f3f40000f3f400004444000044440000fcf60000fcf6000066660000666600
0fffff990fffff0009999990f999999f0fffff440fffff0004444440f444444f0ffff4000ffff40000444400f0ffff0f0ffff6000ffff60000666600f0ffff0f
00ffff00f0ffff0f099999900f6666f000ffff00f0ffff0f044444400faaaaf000444f00f0444f0f00ffff000f8888f000666f00f0666f0f00ffff000fbbbbf0
0f6666f00f6666f00f6666f0006666000faaaaf00faaaaf00faaaaf000aaaa000f8888f00f8888f00f8888f0001111000fbbbbf00fbbbbf00fbbbbf000222200
f066660f00666600f066660f00200200f0aaaa0f00aaaa00f0aaaa0f05000050f011110f00111100f011110f05000050f022220f00222200f022220f00700700
00200200002002000020020000000000005005000500500000500500000000000050050005000050005005000000000000700700007007000070070000000000
00999900099999000099990009999990004444000444440000444400044444400044440000444400004444000044440000666600006666000066660000666600
0999ff009999ff000999999099ffff990444ff004444ff00044ff44044ffff440044ff000044ff000044440000ffff000066ff000066ff000066660000ffff00
999f3f00999f3f0009ffff90993ff399444f1f00444f1f0004ffff40441ff144004f3f00004f3f0000ffff00003ff300006fcf00006fcf0000ffff0000cffc00
99fffff000fffff0993ff399f0ffff0f44fffff000fffff0441ff144f0ffff0f004ffff0004ffff0003ff300f044440f006ffff0006ffff000cffc00f066660f
00ffff00f0ffff0f99ffff990f6666f000ffff00f0ffff0f44ffff440faaaaf000f44400f0f4440f004444000f8888f000f66600f0f6660f006666000fbbbbf0
0f6666f00f6666f00f6666f0006666000faaaaf00faaaaf00faaaaf000aaaa000f8888f00f8888f00f8888f0001111000fbbbbf00fbbbbf00fbbbbf000222200
f066660f00666600f066660f00200200f0aaaa0f00aaaa00f0aaaa0f05000050f011110f00111100f011110f05000050f022220f00222200f022220f00700700
00200200002002000020020000000000005005000005005000500500000000000050050005000050005005000000000000700700007007000070070000000000
000000000000000000000000000000000000000000000000cccccccceeeeeeee9999999922222222aaaaaaaabb444bbb11444111ff444fff8844488800444000
088888800888888001111110011111100555555005555550cccc333ceeee333e9999333922223332aaaa333ab4e8e4bb14e8e411f4e8e4ff84e8e48804e8e400
888a88a88a88a888111b11b11b11b111555e55e55e55e555ccc3ccc3eee3eee39993999322232223aaa3aaa34ae4e84b4ae4e8414ae4e84f4ae4e8484ae4e840
888998999989988811133133331331115552252222522555cc838cccee838eee9983899922838222aa838aaa4e404e4b4e404e414e404e4f4e404e484e404e40
888888888888888811111111111111115555555555555555c88888cce88888ee9888889928888822a88888aa48e48a4b48e48a4148e48a4f48e48a4848e48a40
008888000088880000111100001111000055550000555500c88888cce88888ee9888889928888822a88888aab4aee4bb14aee411f4aee4ff84aee48804aee400
080000800800008001000010010000100500005005000050c88888cce88888ee9888889928888822a88888aabb444bbb11444111ff444fff8844488800444000
800000088000000810000001100000015000000550000005cc888cccee888eee9988899922888222aa888aaabbbbbbbb11111111ffffffff8888888800000000
cccccccccc6ccccceeeeeeeeee6eeeeebbbbbbbbbb6bbbbb9999999999999999aaaaaaaaaa6aaaaa2222222222622222055550655550556700003b3033000033
ccccccccc6cccccceeeeeeeee6eeeeeebbbbbbbbb6bbbbbb9999999999999999aaaaaaaaa6aaaaaa22222222262222225556000655005566033b3bb00003b333
ccc7cccc7ccccccceee7eeee7eeeeeeebbb7bbbb7bbbbbbb9999996999999979aaa7aaaa7aaaaaaa22272222722222225760650000005656bbb33b330033b330
cc7cccccccccccccee7eeeeeeeeeeeeebb7bbbbbbbbbbbbb9969979999999799aa7aaaaaaaaaaaaa2272222222222222556055550650565533333b300b33bbb0
c7cccccccccccc6ce7eeeeeeeeeeee6eb7bbbbbbbbbbbb6b9699799999997999a7aaaaaaaaaaaa6a2722222222222262500055560550055033bbbb303bb33330
ccccccccccccc6cceeeeeeeeeeeee6eebbbbbbbbbbbbb6bb6999999999969999aaaaaaaaaaaaa6aa22222222222226220055055505550000003bb30033bb3333
cccccccccccc7ccceeeeeeeeeeee7eeebbbbbbbbbbbb7bbb9999999999999999aaaaaaaaaaaa7aaa2222222222227222055505550555006730000000330b000b
cccccccccccccccceeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb9999999999999999aaaaaaaaaaaaaaaa2222222222222222055500600056006630033bbb000b333b
cccccccccccccccceeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb9999999999999999aaaaaaaaaaaaaaaa22222222222222220555500550000556003bbbbb003bbbbb
cccccccccccccccceeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb9999999999999999aaaaaaaaaaaaaaaa2222222222222222055670555505555503bb333300033333
cccccc6ccccccc7ceeeeee6eeeeeee7ebbbbbb6bbbbbbb7b9999996999999979aaaaaa6aaaaaaa7a222222622222227205660056700565553bb3333b00003333
cc6cc7ccccccc7ccee6ee7eeeeeee7eebb6bb7bbbbbbb7bb9969979999999799aa6aa7aaaaaaa7aa226227222222272200000000000000553bb33bb3003bbbbb
c6cc7ccccccc7ccce6ee7eeeeeee7eeeb6bb7bbbbbbb7bbb9699799999997999a6aa7aaaaaaa7aaa262272222222722255555056005550003bb33b3300333b3b
6cccccccccc6cccc6eeeeeeeeee6eeee6bbbbbbbbbb6bbbb69999999999699996aaaaaaaaaa6aaaa622222222226222205550056505555550333bb330033333b
cccccccccccccccceeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb9999999999999999aaaaaaaaaaaaaaaa2222222222222222675500555055555603b3bb3030033bbb
cccccccccccccccceeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb9999999999999999aaaaaaaaaaaaaaaa2222222222222222665500555000056603b03330b3000b33
1111111111611111ffffffffff6fffff8888888888688888444444444464444433333333336333335555555555655555dddddddddd6ddddd3333333304004004
1111111116111111fffffffff6ffffff8888888886888888444444444644444433333333363333335555555556555555ddddddddd6dddddd4433333304444444
1117111171111111fff7ffff7fffffff8887888878888888444744447444444433373333733333335557555575555555ddd7dddd7ddddddd4443404404404404
1171111111111111ff7fffffffffffff8878888888888888447444444444444433733333333333335575555555555555dd7ddddddddddddd4404404404404444
1711111111111161f7ffffffffffff6f8788888888888868474444444444446437333333333333635755555555555565d7dddddddddddd6d0004049004904499
1111111111111611fffffffffffff6ff8888888888888688444444444444464433333333333336335555555555555655ddddddddddddd6dd0404449444494409
1111111111117111ffffffffffff7fff8888888888887888444444444444744433333333333373335555555555557555dddddddddddd7ddd4404449000444909
1111111111111111ffffffffffffffff8888888888888888444444444444444433333333333333335555555555555555dddddddddddddddd0004449040044904
1111111111111111ffffffffffffffff8888888888888888444444444444444433333333333333335555555555555555dddddddddddddddd4444444400000049
1111111111111111ffffffffffffffff8888888888888888444444444444444433333333333333335555555555555555dddddddddddddddd4499000904999000
1111116111111171ffffff6fffffff7f8888886888888878444444644444447433333363333333735555556555555575dddddd6ddddddd7d0000040009444444
1161171111111711ff6ff7fffffff7ff8868878888888788446447444444474433633733333337335565575555555755dd6dd7ddddddd7dd4044440400444004
1611711111117111f6ff7fffffff7fff8688788888887888464474444444744436337333333373335655755555557555d6dd7ddddddd7ddd4400004444444440
61111111111611116ffffffffff6ffff68888888888688886444444444464444633333333336333365555555555655556dddddddddd6dddd0094444440404444
1111111111111111ffffffffffffffff8888888888888888444444444444444433333333333333335555555555555555dddddddddddddddd0000440044000004
1111111111111111ffffffffffffffff8888888888888888444444444444444433333333333333335555555555555555dddddddddddddddd4490000444499994
c4c44454d4c4455545554555454555c5e4e4e4e4e4f5e4d506160616c416c316160607171617d4e4e4e4e5f5f5f5c4363636363636d527c53636d436c5d5e4e4
e4e5f5f5e4c44757d4574757d457d457c4574757d4e4e5f5f5f4f4e4c566776740667667776777677767776777d4776676677767776777677766766777d4c4d5
d54445554555445444544454d45454d5e4e4e5e4f5f5e4d40717071707170706c40717060616c4e4e4e4e4e4f5e4d536c42726d5c4363626c436363637c4e4e4
e4e4e4f5e4c446c4c44757475747465646564656c5e4e4e4f5e4e4e4d4667666666777667666c466766676667666666777c4766676667666666777d4766676c5
d445445444544555c4554555455555c4e4e4e5e5f5e4e4d50616061606060607170707070717d4e4e4e4e5e5e5e5c4273736c4263626363627c5363636c5e4e4
f4f4e4e4e4c54757c4d4d44656464757c4574757c4e4e4e4e4e4e4e4c5667666766676667666766676667666c466766676667666766676c476667666766676c5
d544d4554454445444544454445454d5e4e4e4e5f5f5e4d4071707d507d507061606061606c4d5e4e4e4e5e4f5f5c42636c4c5273736c43636c5363637c4e4e4
e4e4e4e4e4d446c55747d4c4c456d4564656c4c4d4e4e4e4e4e400e4d46777677767776777667667d466766777677767776777667667776777677767776676d4
c54555445455455545c54555455555d5e4e4e4e4e4f5e4d5d416c516061606160616c41707c5c4e4e4e4e5e5f5e4d536d4d536263636d5363636d54036c4e4e4
e4e4e4e4e4c44757564647c54757c45747c440c5c4e4e5e5e5e5f4f4d56676c477d4766676677766766777667667d466766676677766766777667666406777d5
d4445445c444544454445444544454c4e4e4e5e5e5e5e4c4d5160606061606c5061607170616d4e4e4e4e4e5f5f5c4d52636372736363627c43636c5d4c5e4e4
e4e4e4e4e4c446c4c447465646c44656c540f740c4e4e5e4f5f5e4f4c5667766766777677776676777d46767776676c5d46777766767776676677767777667c5
c4455545c5455545554555c4554555c5e4e4e5e4f5f5e4d440170717071716160717071707f7d5e4e4e4e4e4e4f5c4d4f7373727d53637c436273740c5d5e4e4
e4e4e4e4e4d447574746c45747c5475747c440d4c4e4e5e5f5e4e4f4c566776777667677677777776777776777677766767767777767776777667677677766c4
c5c4d5d4c4c4d5c5c4d5d4d5c4c4d5d4e4e4e5e5f5e4e4d5d4c4d4d5d4c5c4d4d5d4c4d5d4d4d4e4e4e4e4e4e4e4c4c5c4d5d4d5c5c4c4d4c5c5d5d5c5c5e4e4
e4e4e4e4e4c4c5d4c4c4c5c4d4c4c5c4d4c4c5c4c4e4e4e5f5f5f4f4d5d4c5c5d4c5c5c5d5c5d4c5c5d4c5d5c5c5d4d5c5c5d4c5d5c5c4c5d5c5c4c5c5d5c5c5
e4f4f4e4f4f4e4f4e4f4e4f4e4f4e4f4e4e4e4e5f5f5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e5e5f4f4e4e4e4e5e5e4f4e4e5f5f5f4f4e4e4
e4e5e5e5e5f4f4e5e5e5e5f4f4e5e5e5e5f4f4e4e4e4e4e4e4f5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e5e5f4f4e4e4e5e5e5e5e5f4f4e4
e4e4e4e5e5e4e4e4e5e5e4e4e5e5e4e4e4e4e4e4e4f5e4e5e5e4e4e5e5e4e4e4e5e5e5e5e5e5f4f4e5e5f4f4e5e5e5f4f4f4e4e5e5e5e5f4e4e4e4f5e4e4e4e4
e4e5e4f5f5e4f4e5e4f5f5e4f4e5e4f5f5e4f4e4e4e4e4e4e5e5e5e5f4f4e4e4e5e5e5e5f4f4e5e5e5e5f4f4e5e5e5e5e5e4f5f5e4f4e5e5e5e5e5e5e5e5f4f4
e4e4e5e5e5e5e4e5e5e5e5e5e5e5e5e5e4e5e5e5e5e4e5e5e5e5e5e5e5e5e4e4e5e4e5e4f5f5e4f4f5f5e4f4e4f5f5e4f4f4e4e5e4f5f5f4e5e5e5e5f4f4e5e5
e5e5f4f4e4e4f4e5e5f5e4e4f4e5e5f5e4e4f4e4e4e4e4e4e5e4f5f5e4f4e4e4e5e4f5f5e4f4e5e4f5f5e4f4e5e4f5e5e5e5f5e4e4f4f5f5e5e5e5e4f5f5e4f4
e4e4e5e4f5f5e4e5e4f5f5e5e4f5f5f5e4e5e4f5f5e4e5e4f5f5e5e4f5f5e4e4e5e5e5e5f5e4e4f4f5e4e4f4e5f5e4e4f4f4e4e5e5f5e4f4e5e4f5f5e4f4e5e4
f5f5e4f4f5f4f4e4e5f5f5f4f4e4e5f5f5f4f4e4e4e4e5e5e5e5f4f4e4f4e4e4e5e5f5e4e4f4e5e5f5e4e4f4e5e5f5e5e4e5f5f5f4f4f5e4e4e4e5e5f5e4e4f4
e4e4e5e5f5e4e4e5e5f5e4e5e5f5e4e4e4e5e5f5e4e4e5e5f5e4e5e5f5e4e4e4e4e5e4e5f5f5f4f4f5f5f4f4e5f5f5f4f4f4e4e4e5f5f5f4e5e5f5e4e4f4e5e5
f5e4e4f4f5e4e4e4e4e4f5e4e4e4e4e4f5e4e4e4e4e4e5e4f5f5e4f4f4f4e4e4e4e5f5f5f4f4e4e5f5f5f4f4e4e5f5e4e4e4e4f5e4e4f5f5e4e4e4e5f5f5f4f4
e4e4e4e5f5f5e4e4e5f5f5e4e5f5f5f5e4e4e5f5f5e4e4e5f5f5e4e5f5f5e4e4e4e4e4e4e4f5e4e4e4f5e4e4e4e4f5e4e4e4e4e4e4e4f5e4e4e5f5f5f4f4e4e5
f5f5f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5f5e4e4f4e4e4e4e4e4e4e4f5e4e4e4e4e4f5e4e4e4e4e4e4e4e4e4f5e4e4e4f5e4e4e4e4e4f5e4e4
e4e4e4e4e4f5e4e4e4e4f5e4e4e4f5f5e4e4e4e4f5e4e4e4e4f5e4e4e4f5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f5e4e4e4e5
e5e5e5f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f5f5f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e4e4c4d4c5c5c4c5c5c4d4c5c4c5c5c4c5d5e4e4e4e4e4e4e4d4c5c4d5c5c5c4d5c5c5c4c5c5c4c5d4e4e5
e4f5f5e4f4c4d5c5c4d5c5c4c5c5c4c5c4c5c4c4d5e4e4e4e4f5e4e4d4d5d4d4c5d4d4d5d5c5d5d4d5d4d4c4c5c4d5c5d5c5d5d5c5c4d5c5d5d5c5d5d5c5d5d5
c42626c4c43626c4263626d426d4d4d4e4e4e5e5e5e5e4c5969686c486968696869686c58696c5e4e4e4e5e5e4e4d5e0b6c4b6a6b6a6b6a6b67060a6b6c5e4e5
e5f5e4e4f4c5d0c4d6c6d6d5d6c6c6d6c6d4c6d6c5e4e4e4e4e4e4e4c4f024a624d4a5c44615d435451727b6c6948674841574806537c4c467c4b637475767c4
2634352736252536253535262426d4d4e4e4e5e4f5f5e4c58797879787c5869686d586968696c4e4e4e5e5e5e5e4c4a7b7a7b7a7b7a6a6d4b7a7b7a7b7c4e4e4
e5f5f5f4f4d5c6c4d7c7d7c7d7c7c7d7c7d7c7d7c4e4e4e4e4e4e4e4d53434d42696a6c447167536d4c4d4d5d4d4d5d4d4d4d516d4c47484c4846515d5c565c5
2426263635372725372436242527d427e4e4e4e5e5e4e4c4868696868696c597879787968797c5e4e4e5e4f5f5e4c5a6b6c4b670b6a6a7b7a7b7a7a660c5e4e5
e5e5e5f4f4c4c770c6d6d6c6d6d6c6c470d6c6d6c5e5e5e5e5e5f4f4c5c4d5c4c4a4d4c4a43545d470b66660851470608470959560d5751626a4c5d5d6d626c5
25352636343435353734273654262744e4e4e5e5e5e5e4c48787d5d48797c4d4869686968696c4e4e4e5e5f5e4e4d5d4a6a7b7a7b7a7d4b6a6a7b780b7d4e4e5
e4f5f5e4f4c5c6d4c7d7d7c7d7d7c7d7c7c660d4d5e5e5e4f5f5e4f4c53646d48674d4607480d4374757677686961675162696a637354517d5c42735451727c4
34272736349090343735373645442644e4e4e5e4f5f5f5c586c4969687978797d597d4868797d5e4e4e4e5e5e4e4c5a650a6b6a6b6a6b6a6b6a6b6a680c4e4e5
e5f5e4e4f4d4c7d6c6d6c6d6d670d6d6c6c7c7c6d4e5e5e5f5e4e4f4d57046566675851675c4751550d46557a58035a417c6b63560704076c476863646d586c5
d5252536349090253635262655275454e4e4e5e5f5e4e4d487d497c48696869686c5c4c49696d4e4e4e5e5e5e5e4c4a7b7a770a7c4a7b7a7b7a7b7a780c5e4e4
e5f5f5f4f4d450d6c7d7c730d6c750d6c6d6c6d6c5e5e4e5f5f5f4f4c53747d41580846595d43616c5c526709437507076507484705050d4d4766636465666d5
d5363636363636363636363644372655e4e4e4e5f5f5e4c586d59696c4d48797879787d48797c5e4e4e5e4f5f5e4c5a670a6b6a6b6a6b6a6b6a6b6a6b6c5e4e5
e5e5e5f4f4c4d4d7d670d6d740d7c7d7c7d7c7c6d4e4e4e4e4f5e4e4d51574841675c42696c437c54517c4d4c550c4d4d5d4d48595d447576757c5374757d4c4
c4262636363636363636363626363637e4e4e4e4e4f5e4c55080d497c59686c4868696878696c4e4e4e5e5f5e4e4d540b7a7b7a7b6a6b680b6a7b7a7c4d4e4e5
e4f5f5e4f4c4c6d6c6d6d7d6c6d6c6d6c4d6c6c5d5e4e4e4e4e4e4e4c570601635451727b6d494c4465586748030704656667550d4374757675436d4d51626c4
c4a4b426363636363636363636363636e4e4e4e5e5e4e4c4c486c48696869686968797c58697c4e4e4e4e5f5f5e4c5a6b6a6b670b6a7b7a7c5a6b6a680d5e4e5
e5f5e4e4f4c5c7d7c4d7c7d7c7d7c7f6d5d7c4d7d5e4e5e5e5e5f4f4d58674841580846537d457678674c5c4c56065c4d4d4c5c416751626c4a63735451727c5
b43636b5363626462636363636363636e4e4e5e5e5e5e4c58787978797d59787978696878680d4e4e4e4e4e4f5e4d4a7b7a750a6b6a670a6b6a6b6a750c5e4e4
e5f5f5f4f4c4c6d6c6d6c5d650d6d6d6c6d6c680c4e4e5e4f5f5e4f4c57575851675c42615c584656675c416b416c515706065c435a417d4b6c694d4467686d5
b4363636363636261404053636646536e4e4e5e4f5f5e4c58686968696869686d587c4877060c5e4e4e4e4e4e4e4c5a6b6a6b6a7b7d4b7a7b7a7b7a680c4e4e4
e4e4f5e4e4d5c7d7c7d7c7d7c7c6c7d7c7d7c4c6d5e4e5e5f5e4e4f4d41574846595a5361675c42615d4846595c5c516751626c5364676c5748494364656d4c4
c4a5a4368436364705272704643636d4e4e4e5e5f5e4e4d487879787c4879787978786968096c4e4e4e4e4e4e4e4c450b780b6a6b6a6b6a6b6a6b660b6d5e4e5
e5e5e5f4f4d4c6d6c6d6c6d6c6d6c5d6c6d6c6d6c4e4e5e5e5e5f4f4c5707516d596a637354517c4167516c596a6609694b527c43646d46675d595a4a55767c4
c43636a48536364615272705656436d4e4e4e4e5f5f5e4d586508686968696d5968687d59697c5e4e4e4e4e4e4e4c57050a6b6a7b750b7a7b780b7a7b7c5e4e5
e4f5f5e4f4d4c7d7c7c4c7d7c7d7c780c7d7c7d7d5e4e5e4f5f5e4f4d470451727b6509494d47686c5c4d4c4b6c694b446a48635d4451727b6c69436467686c4
b53636a48436365715272704753636d4e4e4e4e4e4f5e4c48786879686c48696869686c48696c5e4e4e4e4e4e4e4d5a7c5a6b6a6b6a6b680b6a6b6a6b6c4e4e5
e5f5e4e4f4d5c6d650c680c6d650d6c6d6c6d680c4e4e5e5f5e4e4f4d43646768674849436465666c540c435705070365070663660d5d4867484943646d566c5
37a4a537278585461414142736747436e4e4e4e4e4e4e4c5e7968697879787978797879650b0c4e4e4e4e4e4e4e4c4a7b7a7b750a6b680a730a7b7a7e7d4e4e4
e5f5f5f4f4c5c7d7c7c7d7c7d7c7d7c7c4c7d7c4d5e4e4e5f5f5f4f4d53646566675858070475767d45074b47585953647572517804656d47585d5554757f6d4
c43737d4d4272736272727d4d43636d4e4e4e4e4e4e4e4c5d4c5c4c5c5c4c5c5d4c5c4c5d4c5d5e4e4e4e4e4e4e4c5c4c5c5d5c5c4d5c5c5d4c4c4c5c5c4e4e4
e4e4f5e4e4c4c4d5d5c4c5d4c4d4c5d5c5c4c4c5c5e4e4e4e4f5e4e4d4d5c5d5d4d5d4d5d5c5c4d5c5c5d5c5c5d5c5c5c4d5c5c4c5d5d5d4d5d5d4d5c5d5d4d5
__label__
05555065ffffffffffffffff0555506505555065ff6fffffffffffff05555065ffffffffff6fffffffffffff55505567ffffffff555055675550556755505567
55560006ffffffffffffffff5556000655560006f6ffffffffffffff55560006fffffffff6ffffffffffffff55005566ffffffff550055665500556655005566
57606500fff7fffffff7ffff57606500576065007ffffffffff7ffff57606500fff7ffff7ffffffffff7ffff00005656fff7ffff000056560000565600005656
55605555ff7fffffff7fffff5560555555605555ffffffffff7fffff55605555ff7fffffffffffffff7fffff06505655ff7fffff065056550650565506505655
50005556f7fffffff7ffffff5000555650005556ffffff6ff7ffffff50005556f7ffffffffffff6ff7ffffff05500550f7ffffff055005500550055005500550
00550555ffffffffffffffff0055055500550555fffff6ffffffffff00550555fffffffffffff6ffffffffff05550000ffffffff055500000555000005550000
05550555ffffffffffffffff0555055505550555ffff7fffffffffff05550555ffffffffffff7fffffffffff05550067ffffffff055500670555006705550067
05550060ffffffffffffffff0555006005550060ffffffffffffffff05550060ffffffffffffffffffffffff00560066ffffffff005600660056006600560066
ffffffffee6eeeeeeeeeeeeeffffffffff6fffffeeeeeeeeeeeeeeeeff6fffffeeeeeeeeeeeeeeeeeeeeeeeeffffffffeeeeeeeeffffffff5550556755505567
ffffffffe6eeeeeeeeeeeeeefffffffff6ffffffeeeeeeeeeeeeeeeef6ffffffeeeeeeeeeeeeeeeeeeeeeeeeffffffffeeeeeeeeffffffff5500556655005566
fff7ffff7e000e000e000e700ff00f6f7f0f0fffee000e600eeeee600f000f000e000e000eeeee7eeeeeee7efff7ffffeee7eeeefff7ffff0000565600005656
ff7fffffee0e0e0e0e0ee70eff0ff7ffff0f0fffee60e70e0e6ee70efff0ff0f0e0e07e0eeeee7eeeeeee7eeff7fffffee7eeeeeff7fffff0650565506505655
f7ffffffee000e00ee007e0006000ffffff0ff6fe6e07e0e06ee7e000ff0ff0006007ee0eeee7eeeeeee7eeef7ffffffe7eeeeeef7ffffff0550055005500550
ffffffffee0ee60e0e06eeee0fff0fffff0f06ff6ee0ee0e0eeeeeee0ff0f60f0e0e0ee0eee6eeeeeee6eeeeffffffffeeeeeeeeffffffff0555000005550000
ffffffffee0e7e0e0e000e00ff00ffffff0f0fffeee0ee00eeeeee00fff07f0f0e0e0ee0eeeeeeeeeeeeeeeeffffffffeeeeeeeeffffffff0555006705550067
ffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffeeeeeeeeeeeeeeeeeeeeeeeeffffffffeeeeeeeeffffffff0056006600560066
eeeeeeeeffffffffffffffffff6fffffeeeeeeeeffffffffffffffffeeeeeeeeffffffffeeeeeeeeff6fffffeeeeeeeeeeeeeeeeffffffff55505567ffffffff
eeeeeeeefffffffffffffffff6ffffffeeeeeeeeffffffffffffffffeeeeeeeeffffffffeeeeeeeef6ffffffeeeeeeeeeeeeeeeeffffffff55005566ffffffff
eee7eeeeff07ff000f070f000f0fffffee00ee7effffff7fffffff6feeeeee6effffff7feee7eeee7fffffffeee7eeeeeeeeee6effffff6f00005656ffffff6f
ee7eeeeeff0fff0fff0f0f0fff0fffffeee0e7eefffff7ffff6ff7ffee6ee7eefffff7ffee7eeeeeffffffffee7eeeeeee6ee7eeff6ff7ff06505655ff6ff7ff
e7eeeeeef70fff00f70f0f00ff0fff6feee07eeeffff7ffff6ff7fffe6ee7eeeffff7fffe7eeeeeeffffff6fe7eeeeeee6ee7eeef6ff7fff05500550f6ff7fff
eeeeeeeeff0fff0fff000f0fff0ff6ffeee0eeeefff6ffff6fffffff6eeeeeeefff6ffffeeeeeeeefffff6ffeeeeeeee6eeeeeee6fffffff055500006fffffff
eeeeeeeeff000f000ff0ff000f000fffee000eeeffffffffffffffffeeeeeeeeffffffffeeeeeeeeffff7fffeeeeeeeeeeeeeeeeffffffff05550067ffffffff
eeeeeeeeffffffffffffffffffffffffeeeeeeeeffffffffffffffffeeeeeeeeffffffffeeeeeeeeffffffffeeeeeeeeeeeeeeeeffffffff00560066ffffffff
eeeeeeeeeeeeeeeeffffffffff6fffffee6eeeeeee6eeeeeeeeeeeeeeeeeeeeeffffffffee6eeeeeffffffffff6fffffbb6bbbbbffffffffffffffffbbbbbbbb
eeeeeeeeee000e000ff00f0006fffff006e00ee006000e000eeeeeeeeeeeee0e0fffffffe6eeeeeefffffffff6ffffffb6bbbbbbffffffffffffffffbbbbbbbb
eeeeee6eee0e0e0eff07fff07fffff0f7e0eee0e0e0e0e0eeeeeee70eeeeee0e0fffff7f7eeeeeeeffffff6f7fffffff7bbbbbbbfff7ffffffffff6fbbb7bbbb
ee6ee7eeee00e700ff000ff0ffffff000e0eee0e0e00ee00eeeee7eeeeeee7000ffff7ffeeeeeeeeff6ff7ffffffffffbbbbbbbbff7fffffff6ff7ffbb7bbbbb
e6ee7eeeee0e0e0ef7ff0ff0ffffff6f0e0eee0e0e0e0e0eeeee7ee0eeee7eee0fff7fffeeeeee6ef6ff7fffffffff6fbbbbbb6bf7fffffff6ff7fffb7bbbbbb
6eeeeeeeee000e000f00fff0fffff600eee00600ee0e06000ee6eeeeeee6eeee0ff6ffffeeeee6ee6ffffffffffff6ffbbbbb6bbffffffff6fffffffbbbbbbbb
eeeeeeeeeeeeeeeeffffffffffff7fffeeee7eeeeeee7eeeeeeeeeeeeeeeeeeeffffffffeeee7eeeffffffffffff7fffbbbb7bbbffffffffffffffffbbbbbbbb
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffffeeeeeeeeffffffffffffffffbbbbbbbbffffffffffffffffbbbbbbbb
50000556ffffffffffffffffff6fffffee6eeeeeccccccccccccccccee6eeeeeffffffffeeeeeeeeffffffffff6fffffbbbbbbbbbbbbbbbbffffffffbbbbbbbb
55055555fffffffffffffffff6ffffffe6eeeeeecccc333ccccc333ce6eeeeeeffffffffeeeeeeeefffffffff6ffffffbbbbbbbbbbbbbbbbffffffffbbbbbbbb
70056555ffffff6fffffff6f7fffffff7eeeeeeeccc3ccc3ccc3ccc37eeeeeeeffffff7feeeeee7effffff7f7fffffffbbbbbb6bbbb7bbbbfff7ffffbbb7bbbb
00000055ff6ff7ffff6ff7ffffffffffeeeee0eecc838cc666638ccceee0eeeefffff7ffeeeee7eefffff7ffffffffffbb6bb7bbbb7bbbbbff7fffffbb7bbbbb
00555000f6ff7ffff6ff7fffffffff6feeee0e6ec88888c6666888cceeee0e6effff7fffeeee7eeeffff7fffffffff6fb6bb7bbbb7bbbbbbf7ffffffb7bbbbbb
505555556fffffff6ffffffffffff6ffeee0e6e0008888cffff888c000eee0eefff6ffffeee6eeeefff6fffffffff6ff6bbbbbbbbbbbbbbbffffffffbbbbbbbb
50555556ffffffffffffffffffff7fffeeee0eeec88888ccffc888cceeee0eeeffffffffeeeeeeeeffffffffffff7fffbbbbbbbbbbbbbbbbffffffffbbbbbbbb
50000566ffffffffffffffffffffffffeeeee0eecc888cc666688ccceee0eeeeffffffffeeeeeeeeffffffffffffffffbbbbbbbbbbbbbbbbffffffffbbbbbbbb
50000556eeeeeeeeeeeeeeeeff6fffffee6eeeeeccccccfbbbbfcccceeeeeeeeff6fffffeeeeeeeeffffffffffffffffbbbbbbbbffffffffbb6bbbbbbb6bbbbb
55055555eeeeeeeeeeeeeeeef6ffffffe6eeeeeecccc3f32222cf33ceeeeeeeef6ffffffeeeeeeeeffffffffffffffffbbbbbbbbffffffffb6bbbbbbb6bbbbbb
70056555eeeeee6eeeeeee6e7fffffff7eeeeeeeccc3ccc7cc73ccc3eeeeee6e7fffffffeeeeee7efff7fffffff7ffffbbbbbb7bffffff6f7bbbbbbb7bbbbbbb
00000055ee6ee7eeee6ee7eeffffffffeeeeeeeecc838ccccc838cccee6ee7eeffffffffeeeee7eeff7fffffff7fffffbbbbb7bbff6ff7ffbbbbbbbbbbbbbbbb
00555000e6ee7eeee6ee7eeeffffff6feeeeee6ec88888ccc88888cce6ee7eeeffffff6feeee7eeef7fffffff7ffffffbbbb7bbbf6ff7fffbbbbbb6bbbbbbb6b
505555556eeeeeee6eeeeeeefffff6ffeeeee6eec88888ccc88888cc6eeeeeeefffff6ffeee6eeeeffffffffffffffffbbb6bbbb6fffffffbbbbb6bbbbbbb6bb
50555556eeeeeeeeeeeeeeeeffff7fffeeee7eeec88888ccc88888cceeeeeeeeffff7fffeeeeeeeeffffffffffffffffbbbbbbbbffffffffbbbb7bbbbbbb7bbb
50000566eeeeeeeeeeeeeeeeffffffffeeeeeeeecc888ccccc888ccceeeeeeeeffffffffeeeeeeeeffffffffffffffffbbbbbbbbffffffffbbbbbbbbbbbbbbbb
50000556ff6fffffff6fffff05555065ffffffff5550556755505567ffffffff05555005ffffffff05555005ff6fffffbbbbbbbbffffffffffffffffbbbbbbbb
55055555f6fffffff6ffffff55560006ffffffff5500556655005566ffffffff05567055ffffffff05567055f6ffffffbbbbbbbbffffffffffffffffbbbbbbbb
700565557fffffff7fffffff57606500ffffff7f0000565600005656fff7ffff05660056fff7ffff056600567fffffffbbb7bbbbffffff7ffff7ffffbbbbbb7b
00000055ffffffffffffffff55605555fffff7ff0650565506505655ff7fffff00000000ff7fffff00000000ffffffffbb7bbbbbfffff7ffff7fffffbbbbb7bb
00555000ffffff6fffffff6f50005556ffff7fff0550055005500550f7ffffff55555056f7ffffff55555056ffffff6fb7bbbbbbffff7ffff7ffffffbbbb7bbb
50555555fffff6fffffff6ff00550555fff6ffff0555000005550000ffffffff05550056ffffffff05550056fffff6ffbbbbbbbbfff6ffffffffffffbbb6bbbb
50555556ffff7fffffff7fff05550555ffffffff0555006705550067ffffffff67550055ffffffff67550055ffff7fffbbbbbbbbffffffffffffffffbbbbbbbb
50000566ffffffffffffffff05550060ffffffff0056006600560066ffffffff66550055ffffffff66550055ffffffffbbbbbbbbffffffffffffffffbbbbbbbb
05555065ffffffffffffffff055550650555506555505567555055675550556705555005055550050555500550000556ffffffff0555500505555005ffffffff
55560006ffffffffffffffff555600065556000655005566550055665500556605567055055670550556705555055555ffffffff0556705505567055ffffffff
57606500fff7fffffff7ffff576065005760650000005656000056560000565605660056056600560566005670056555fff7ffff0566005605660056ffffff7f
55605555ff7fffffff7fffff556055555560555506505655065056550650565500000000000000000000000000000055ff7fffff0000000000000000fffff7ff
50005556f7fffffff7ffffff500055565000555605500550055005500550055055555056555550565555505600555000f7ffffff5555505655555056ffff7fff
00550555ffffffffffffffff005505550055055505550000055500000555000005550056055500560555005650555555ffffffff0555005605550056fff6ffff
05550555ffffffffffffffff055505550555055505550067055500670555006767550055675500556755005550555556ffffffff6755005567550055ffffffff
05550060ffffffffffffffff055500600555006000560066005600660056006666550055665500556655005550000566ffffffff6655005566550055ffffffff
055550652222222222622222ffffffff055550655550556755505567ffffffff0555500505555005055550055000055650000556055550050555500505555005
555600062222222226222222ffffffff555600065500556655005566ffffffff0556705505567055055670555505555555055555055670550556705505567055
576065002227222272222222fff7ffff576065000000565600005656fff7ffff0566005605660056056600567005655570056555056600560566005605660056
556055552272222222222222ff7fffff556055550650565506505655ff7fffff0000000000000000000000000000005500000055000000000000000000000000
500055562722222222222262f7ffffff500055560550055005500550f7ffffff5555505655555056555550560055500000555000555550565555505655555056
005505552222222222222622ffffffff005505550555000005550000ffffffff0555005605550056055500565055555550555555055500560555005605550056
055505552222222222227222ffffffff055505550555006705550067ffffffff6755005567550055675500555055555650555556675500556755005567550055
055500602222222222222222ffffffff055500600056006600560066ffffffff6655005566550055665500555000056650000566665500556655005566550055
05555065ff6fffffff6fffff22222222ff6fffff55505567ffffffff88888888ffffffffff6fffffff6fffff5000055650000556ff6fffffff6fffff05555005
55560006f6fffffff6ffffff22222222f6ffffff55005566ffffffff88888888fffffffff6fffffff6ffffff5505555555055555f6fffffff6ffffff05567055
576065007fffffff7fffffff222222727fffffff00005656fff7ffff88878888fff7ffff7fffffff7fffffff70056555700565557fffffff7fffffff05660056
55605555ffffffffffffffff22222722ffffffff06505655ff7fffff88788888ff7fffffffffffffffffffff0000005500000055ffffffffffffffff00000000
50005556ffffff6fffffff6f22227222ffffff6f05500550f7ffffff87888888f7ffffffffffff6fffffff6f0055500000555000ffffff6fffffff6f55555056
00550555fffff6fffffff6ff22262222fffff6ff05550000ffffffff88888888fffffffffffff6fffffff6ff5055555550555555fffff6fffffff6ff05550056
05550555ffff7fffffff7fff22222222ffff7fff05550067ffffffff88888888ffffffffffff7fffffff7fff5055555650555556ffff7fffffff7fff67550055
05550060ffffffffffffffff22222222ffffffff00560066ffffffff88888888ffffffffffffffffffffffff5000056650000566ffffffffffffffff66550055
05555065ff6fffffff6fffffff6fffffff6fffff5550556755505567ffffffffcc6cccccccccccccccccccccff6fffffff6fffff9999999999999999ff6fffff
55560006f6fffffff6fffffff6fffffff6ffffff5500556655005566ffffffffc6ccccccccccccccccccccccf6fffffff6ffffff9999999999999999f6ffffff
576065007fffffff7fffffff7fffffff7fffffff0000565600005656fff7ffff7cccccccccc7cccccccccc6c7fffffff7fffffff99999969999999697fffffff
55605555ffffffffffffffffffffffffffffffff0650565506505655ff7fffffcccccccccc7ccccccc6cc7ccffffffffffffffff9969979999699799ffffffff
50005556ffffff6fffffff6fffffff6fffffff6f0550055005500550f7ffffffcccccc6cc7ccccccc6cc7cccffffff6fffffff6f9699799996997999ffffff6f
00550555fffff6fffffff6fffffff6fffffff6ff0555000005550000ffffffffccccc6cccccccccc6cccccccfffff6fffffff6ff6999999969999999fffff6ff
05550555ffff7fffffff7fffffff7fffffff7fff0555006705550067ffffffffcccc7cccccccccccccccccccffff7fffffff7fff9999999999999999ffff7fff
05550060ffffffffffffffffffffffffffffffff0056006600560066ffffffffccccccccccccccccccccccccffffffffffffffff9999999999999999ffffffff
055550652222222222222222ff6fffffaaaaaaaaff6fffffff6fffff88888888ccccccccffffffffffffffffcccccccc99999999ff6fffffff6fffff55505567
555600062222222222222222f6ffffffaaaaaaaaf6fffffff6ffffff88888888ccccccccffffffffffffffffcccccccc99999999f6fffffff6ffffff55005566
5760650022222262222722227fffffffaaa7aaaa7fffffff7fffffff88888868cccccc6cffffff6fffffff6fccc7cccc999999697fffffff7fffffff00005656
556055552262272222722222ffffffffaa7aaaaaffffffffffffffff88688788cc6cc7ccff6ff7ffff6ff7ffcc7ccccc99699799ffffffffffffffff06505655
500055562622722227222222ffffff6fa7aaaaaaffffff6fffffff6f86887888c6cc7cccf6ff7ffff6ff7fffc7cccccc96997999ffffff6fffffff6f05500550
005505556222222222222222fffff6ffaaaaaaaafffff6fffffff6ff688888886ccccccc6fffffff6fffffffcccccccc69999999fffff6fffffff6ff05550000
055505552222222222222222ffff7fffaaaaaaaaffff7fffffff7fff88888888ccccccccffffffffffffffffcccccccc99999999ffff7fffffff7fff05550067
055500602222222222222222ffffffffaaaaaaaaffffffffffffffff88888888ccccccccffffffffffffffffcccccccc99999999ffffffffffffffff00560066
05555065ff6fffffff6fffff22222222aaaaaaaaff6fffffff6fffff88888888ccccccccffffffffffffffffcccccccc9999999999999999ff6fffff55505567
55560006f6fffffff6ffffff22222222aaaaaaaaf6fffffff6ffffff88888888ccccccccffffffffffffffffcccccccc9999999999999999f6ffffff55005566
576065007fffffff7fffffff22272222aaaaaa6a7fffffff7fffffff88878888cccccc7cffffff6fffffff6fcccccc6c99999969999999697fffffff00005656
55605555ffffffffffffffff22722222aa6aa7aaffffffffffffffff88788888ccccc7ccff6ff7ffff6ff7ffcc6cc7cc9969979999699799ffffffff06505655
50005556ffffff6fffffff6f27222222a6aa7aaaffffff6fffffff6f87888888cccc7cccf6ff7ffff6ff7fffc6cc7ccc9699799996997999ffffff6f05500550
00550555fffff6fffffff6ff222222226aaaaaaafffff6fffffff6ff88888888ccc6cccc6fffffff6fffffff6ccccccc6999999969999999fffff6ff05550000
05550555ffff7fffffff7fff22222222aaaaaaaaffff7fffffff7fff88888888ccccccccffffffffffffffffcccccccc9999999999999999ffff7fff05550067
05550060ffffffffffffffff22222222aaaaaaaaffffffffffffffff88888888ccccccccffffffffffffffffcccccccc9999999999999999ffffffff00560066
22222222ff6fffffff6fffff22222222aaaaaaaaff6fffffff6fffff88888888ccccccccffffffffffffffffcccccccc99999999ff6fffffff6fffff55505567
22222222f6fffffff6ffffff22222222aaaaaaaaf6fffffff6ffffff88888888ccccccccffffffffffffffffcccccccc99999999f6fffffff6ffffff55005566
222222727fffffff7fffffff22272222aaa7aaaa7fffffff7fffffff88888878cccccc7cffffff6fffffff6fccc7cccc999999797fffffff7fffffff00005656
22222722ffffffffffffffff22722222aa7aaaaaffffffffffffffff88888788ccccc7ccff6ff7ffff6ff7ffcc7ccccc99999799ffffffffffffffff06505655
22227222ffffff6fffffff6f27222222a7aaaaaaffffff6fffffff6f88887888cccc7cccf6ff7ffff6ff7fffc7cccccc99997999ffffff6fffffff6f05500550
22262222fffff6fffffff6ff22222222aaaaaaaafffff6fffffff6ff88868888ccc6cccc6fffffff6fffffffcccccccc99969999fffff6fffffff6ff05550000
22222222ffff7fffffff7fff22222222aaaaaaaaffff7fffffff7fff88888888ccccccccffffffffffffffffcccccccc99999999ffff7fffffff7fff05550067
22222222ffffffffffffffff22222222aaaaaaaaffffffffffffffff88888888ccccccccffffffffffffffffcccccccc99999999ffffffffffffffff00560066
ffffffff2222222222222222ffffffffffffffffaaaaaaaaaaaaaaaa88888888cc6ccccccc6ccccccc6cccccffffffffff6fffff9999999999999999ff6fffff
ffffffff2222222222222222ffffffffffffffffaaaaaaaaaaaaaaaa88888888c6ccccccc6ccccccc6ccccccfffffffff6ffffff9999999999999999f6ffffff
ffffff7f2227222222222262ffffff7fffffff6faaaaaa6aaaaaaa6a888788887ccccccc7ccccccc7cccccccffffff6f7fffffff99999979999999797fffffff
fffff7ff2272222222622722fffff7ffff6ff7ffaa6aa7aaaa6aa7aa88788888ccccccccccccccccccccccccff6ff7ffffffffff9999979999999799ffffffff
ffff7fff2722222226227222ffff7ffff6ff7fffa6aa7aaaa6aa7aaa87888888cccccc6ccccccc6ccccccc6cf6ff7fffffffff6f9999799999997999ffffff6f
fff6ffff2222222262222222fff6ffff6fffffff6aaaaaaa6aaaaaaa88888888ccccc6ccccccc6ccccccc6cc6ffffffffffff6ff9996999999969999fffff6ff
ffffffff2222222222222222ffffffffffffffffaaaaaaaaaaaaaaaa88888888cccc7ccccccc7ccccccc7cccffffffffffff7fff9999999999999999ffff7fff
ffffffff2222222222222222ffffffffffffffffaaaaaaaaaaaaaaaa88888888ccccccccccccccccccccccccffffffffffffffff9999999999999999ffffffff
05555065ffffffffffffffff5550556755505567ffffffffffffffffff6fffffffffffffffffffffffffffff5550556755505567ff6fffffff6fffff55505567
55560006ffffffffffffffff5500556655005566fffffffffffffffff6ffffffffffffffffffffffffffffff5500556655005566f6fffffff6ffffff55005566
57606500ffffff7fffffff7f0000565600005656ffffff6fffffff6f7fffffffffffff6fffffff6fffffff6f00005656000056567fffffff7fffffff00005656
55605555fffff7fffffff7ff0650565506505655ff6ff7ffff6ff7ffffffffffff6ff7ffff6ff7ffff6ff7ff0650565506505655ffffffffffffffff06505655
50005556ffff7fffffff7fff0550055005500550f6ff7ffff6ff7fffffffff6ff6ff7ffff6ff7ffff6ff7fff0550055005500550ffffff6fffffff6f05500550
00550555fff6fffffff6ffff05550000055500006fffffff6ffffffffffff6ff6fffffff6fffffff6fffffff0555000005550000fffff6fffffff6ff05550000
05550555ffffffffffffffff0555006705550067ffffffffffffffffffff7fffffffffffffffffffffffffff0555006705550067ffff7fffffff7fff05550067
05550060ffffffffffffffff0056006600560066ffffffffffffffffffffffffffffffffffffffffffffffff0056006600560066ffffffffffffffff00560066

__gff__
0000020004208040100100020202020200000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020200000000000000000000000001010000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4c4d4c4c4c4d4c4d4c4c4c4d4c4c4d4c4e4e4e4e4e4e4e5c4d5d4d4d4c5c5c5d4d5c5c4d5c5c5c4e5e5e5e5e4f4f4d4c5d5c5c4d5c5c5d5c4c5c5c4c5d4d5e5e5e5e4f4f4e4c5c5d4c5c5c4c4c4c5c4c4c5c4c5d5c4e5e5e5e5e4f4f4c5c5d4c5c5d4d5c5c5c5d4c5c5c5c5d5c5c5c5d5c5c4c4c5d5c5d5c5d4c4c4c5c5d5c4c
4d3641504151514c4d5151514141414d4e5e5e5e5e4f4f5d424342434243424342434243427e4d4e5e4e5f5f4e4f5c384c4c47465d4c474647464746474d5e4e5f5f4e4f4f4c4a4c4a4b4a4b4a4b4a4b4a4b4a4b4c4e5e4e5f5f4e4f5d484948494849484948494849484948494849484948494849484948494c49484948494c
4c4d4d4d5051515c5c5051404140415c4e5e4e5f5f4e4f4c52535243435352535253525352535d4e5e5e5f4e4e4f5d565c565756574c575657564c5c575d5e5e5f4e4e4f4f4c5a5b5a5d5a5b5a5b5a5b5a5b5c5b4c4e5e5e5f4e4e4f5c5859585958595859584d5d59585958595d4d5859584d584c58594d595859585958594c
5d40414041514041404041505150515c4e5e5e5f4e4e4f5c4243424c5c4c42434243424342435c4e4e5e5f5f4f4f4d464c4647464746474647464746475c4e5e5f5f4f4f4f5c4a4b4a4b4a4b4c4b4a4b4a4b4a4b5c4e4e5e5f5f4f4f4c48494849484948494d49494d4849484d48495d4d5c494849485d48494849484948495c
5d505150514150515050515d5c40414d4e4e5e5f5f4f4f5c5253525343535253524d525352535c4e4e4e4e5f4e4e5c564c4c5756575657565756575c4c5c4e4e4e5f4e4e4f4c5c5b4a5b5a5b5a5b5a5b5a5b5a5b4c4e4e4e4e5f4e4e5d58595d59585958595859585d5859585958594d5d59595859585958595859585958594c
4d404140415140414040414d4050514d4e4e4e4e5f4e4e4c43434343424c4d43425c424342435c4e4e5e5f5f4f4f5d46474c474c4746474647464746475d4e4e4e4e5f4e4e4c4a4b4a5c4a4b4a4b4a4b5c4b4a4b5c4e5e4e5f5f4e4f4c4849484948494849485d484948494849485c4c49594948494d4948584849484948495d
5c505150514150515050514c5040414c4e5e5e5f4e4e4f4d5c4d4c4d4c5352535243525352534c4e4e4e4e5f4e4e4c56575c5756575657564c565756575c4e4e4e4e5f4e4e5c5a5b5a5b5a5b5a5b5a5b5a5b5a5b4c4e5e5e5e5e4f4f5c585958594d5958595859585958595859585958595859584d58595859585d585958594c
4d40414c505140414041414d4050514c5e4e5e5f5f4f4f4c42434243424342434243424342435c4e5e5e5e5e4f4f5d464c4647464d46474647464746475d4e5e5e5f4e4e4f4c4c4b4a4b4a4b4a4b4a4b4a4b4a4b5d4e5e4e5f5f4e4f5d48494849484d4849484948495d49485c484958494849485d484948494849484948495c
4c50514d40415040505151404151514c5e4e4e4e5f4e4e4d52535253525352535253525352535d4e5e4e5f5f4e4f4c56575657565756575657565756574c4e4e5e5f5f4f4f4c5a5b5a5b5a5b4c395a5b5a5b5a4c4c4e5e5e5f4e4e4f4c5859580f585d585958594c4d5859585958594c594d59585958595d5958595859586f5d
4c40404150515050515c4050514d5c5d5e5e5f4e4e4f4e5c42435c43424342434243424342434d4e5e5e5f4e4e4f4d46474647464746474647464c46475d4e4e4e4e5f4e4e5d4a4b4a4b4a4b4a4b4a4c4a4b4a4c4c4e4e5e5f5f4f4f5d48494849484d48495d49485d4849484948495d5848494c49484948494849484948494c
5d504041414d5c5d5d7f505051404c4d4e5e5f5f4f4f4e4d52534c53525352535253525352535c4e4e5e5f5f4f4f5d4c4c5657565756575657565756575c5e5e5e5e4f4f4e5c5a5b4c5b5a5b5a5b5a5b5a5b5a5b5c4e4e4e4e5f4e4e5c585958594d59585958595859585958594d59584c5d4c58595859584d5d59584c58595c
5c4041514c404140414050514140414d4e4e4e5f4e4e4e4c42434c43534342434243424342434c4e4e4e4e5f4e4e5d464746474647464746475d4746475c5e4e5f5f4e4f4e4c4a4b4a4b5c4c4a4b4a4b4a4b4a4b5d4e5e4e5f5f4e4f5d484d4849484948495949484959495d4948494849484948494d4948494849484948494c
4d50514041505150515051505150515d4e4e4e4e4e4e4e4d5253524d4d5352535c53525352535c4e5e5e5e5e4f4f4c565756575657564c5657565756574c5e5e5f4e4e4f4e4c5a5b5c5b5a5b5a5b5a5b4c5b5a4b4c4e5e5e5f4e4e4f4c5859585d4d595859585958595c595859585d4d59584c5859585958595859585958594c
4d40415051404140414041404140414d4e5e5e5e5e4f4f4c4c4d42434c4342434d43424342434c4e5e4e5f5f4e4f5d46474c4c464746474647464746475c4e5e5f5f4f4f4f5c4a4b4a4b4a4b4a4b4a4b4a4b4b4c4d4f4e5e5f5f4f4f5c4849484948494849484948494849484948494849484948495d4c48494849484948495d
5c50515051505150515051505150514c4e5e4e5f5f4e4f4c375352534d5352535c53525352535d4e5e5e5f4e4e4f5d565756575657565d56575657567f4d4e4e4e5f4e4e4f4c5a5b5a5b5a4c5a5b4d5b5a5a5a5a4d4e4e4e4e5f4e4e4c4859585958595859585958595859585958595859585958595859585958594c5958594c
5c5c4c5c5d4d4c5c5c4d4d4c5d4d4d4c4e5e5e5f4e4e4f5c4c5c4d5c5c4c5c5c4d5c5c4c5d4d5c5e4e5e5f5f4f4f5c4c5d5c5d4c5c4c5d5c5d5c4c4d5c5d4e5e5e5f4e4e4f4c5d4c5c4c5c4c5c4c4c5c4c4d4d5c5d4e5e5e5e5e4f4f4c5d5c5d5c4c5c4c4c5c4c5d4c5c4c5d5c4c5c4c5d4c5c4c4c4c5d4c5c5d4c4c5d4c4c5c
4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5f5f4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e4e4e4e5f5e5e5e5e4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e5e5e4f4f5e5e5e5e4f4f4e4e4e4e4e4f4e5e5f5f4f5e4e5f5f4e4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e
5e4e4e5e4f4f4f5e5e5e5e4f5e5e5e5e4f4e4e4e5f4e4e4f5e5e5e5e4f4f4e5e5e5e5e4f4f5e5e5e5e5f4e4e5e4e5f5f4e4f5e5e5e5e5e5e5e5e4f4f5e4f4f5e4e5f5f4e4f5e4e5f5f4e4f5e5e5e5e4f4f4e4e4e5e5e5e5e5f4e4e4f5e4e4e5e5e5e5e4f5e5e5e5e4f4f5e5e5e4f4f4e5e5e5e5e4f4f4e5e5e5e5e5e5e5e4f4f
5e4e4e4e4e4f4f5e4e5f5f4e5e4e5f5f4e4f5e4e5f5f4e4f5e4e5f5f4e4f5e5e5e5e4f4f4f5e4e4e5e5f5f4f5e5e5f4e4e4f5e4e5f5f5e4e5f5f4e4f5f4e4f5e5e5f4e4e4f5e5e5f4e4e4f5e4e5f5f4e4f5e5e5e5e4e4e5e5f5f4f4f4e4e4e5e4e5f5f4e5e4e5f5f4e4f4e5f5f4e4f4e5e4e5f5f4e4f4e5e4e5e5e4e5f5f4e4f
5e5e5f4e4e4f4f5e5e5f4e4e5e5e5f4e4e4f5e5e5f4e4e4f5e5e5f4e4e4f5e4e5f5f4e4f4f5e5e4e4e4e5f4e4e5e5f5f4f4f5e5e5f4e5e5e5f4e4e4f4e4e4f4e5e5f5f4f4f4e5e5f5f4f4f5e5e5f4e4e4f5e4e5f5e5e4e4e4e5f4e4e4e4e4e5e5e5f4e4e5e5e5f4e4e4f5e5f4e4e4f4e5e5e5f4e4e4f4e5e5e5e5e5e5f4e4e4f
4e5e5f5f4f4f4f4e5e5f5f4f4e5e5f5f4f4f4e5e5f5f4f4f4e5e5f5f4f4f5e5e5f4e4e4f4f4e5e5f5f4f4f4e4e4e4e5f4e4e4e5e5f5f4e5e5f5f4f4f5f4f4f4e4e4e5f4e4e4e4e4e5f4e4e4e5e5f5f4f4f5e5e5f4e5e5f5f4f4f4f4f4f4f4e4e5e5f5f4f4e5e5f5f4f4f5e5f5f4f4f4e4e5e5f5f4f4f4e4e5e5e4e5e5f5f4f4f
4e4e4e5f4e4e4e4e4e4e5f4e4e4e4e5f4e4e4e4e4e5f4e4e4e4e4e5f4e4e4e5e5f5f4f4f4e4e4e4e5f4e4e5e5e4e4e4e4e4e4e4e4e5f4e4e4e5f4e4e5f4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e4e4e5f4e4e4e5e5f4e4e4e5f4e4e4f4e4e4e4e4e4e4e5f4e4e4e4e5f4e4e4e4e5f4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e4e5f4e4e
4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e5e5e5e5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f4e4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4f4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4e
4d5c4c4d5d5c5d4c4d4c5d5c4d5d4c4c4e5e5e5e5e4f4f4c4d5d4d4c5d4d5c5c5d5c4d4c5c5c4c4e4e4e5e4e5f5f4c4c5c4c5d5c4c5c4c5c4c4c5c4c5d5c4e4f4e4e4e4f4e4c4d4c5c4d5c4c4c4d4c5c4c4d4c5c4d4e5e4e5e5e4f4f5c5c4d5c4d5c4c5c4d5c5c4d5c5c4d5c5d4d5c5c4d5c5d5c5c5d5c4d5c4d4c5c5c4d5c4d
4c4445444c4c4c444544454544457f4c4e5e4e5f5f4e4f5d616161604d6061606160616060045c4e4e4e5e5e5f4e4c3d63626363634c6363635c6363634c4e4f4e4e4e4e4e4d3e4c64655c6574757475747564654c4e5e4e5f5f4e4f5d666766676667666766676766676667666766676667666766666766676667666766675d
5d4445545554550455545544454c4c5d4e5e5e5f4e4e4f4d7071717071707170714c717070714c4e4e4e4e5e5f5f4c4c5c6363634c63627273636363734c4e4f4e4f4f4e4e5c646564656465644c6465644c74755c4e5e5e5f4e4e4f4d666766676667666766676667666766676667666766676667664c66676667666766675c
4d54554d444544454544540345543b4c4e4e5e5f5f4f4f5d606161606160614c616061604c714d4e4e4e4e4e4e5f4c73734c636363636363636363625d5c4e4f4f4f4e4e4e4c4c7574754d754c75744c744c64654c4e4e5e5f5f4f4f5c7677764d7677767776774c774d0f76777677676676777677760367777677764d76775c
4c4445555455545545444544454d4c4d4e4e4e5e5e4e4e4d704d7170717071707170717061614d4e4e4e4e5e5e4e5c6263635c5c63634c637372735d4d4c4e4e4f4f4e4f4f4c7475644d747564656465646564655c4e4e4e4e5f4e4e5c66674c6766676667666766676667666766676667666766674d6766676667666766674d
4d54554544455c45554c55545454555d4e4e5e5e5e5e4e4d606161606161616061604d6070715d4e4e4e5e5e4e5e4c62636363635c63635c63624d63634c4e4e4e5e5e4e4e5c644c5c75646575755c75747574754d4e4e4e4e4e4e4e5c76777677666776777677767776777677764d666776777677767776776667767776775d
5d444c5554555455454445444444454c4e4e5e4e5f5f4e5d70717170717071707170606160615c4e4e5e5e5e5e5f5c63634c63635c7273635c4d5d63734c4e4e5e5e5e5e4e4d64656465644d6465646564654c654c5e5e5e5e4f4f4e4d6667666776776667666766676667666766677677664c6667666766677677664d66674d
4d4c444d44454445555455545454554d4e4e5e5e5f4e4e5c60616061606160616060707170714d4e4e5e4e5f5f4e4c63635d4d63635d724c63626363635c4e4e5e4e5f5f4e4c74754c7574754d754d754c7574755c5e4e5f5f4e4f4e5c76776667666766676667666766674c77666766676667664d7677666766676667664d5c
5c44545554554445444c44454444455d4e4e4e5e5f5f4e4d70715d714c717003707060614c615d4e4e5e5e5f4e5f4c04635c4c6362630363636362634d4c4e4e5e5e5f4e4e5c5c65644d6465740364654d6564654c5e5e5f4e4e4f4e5d666776774d5c767776777677767766677677767776777677664c767776776666666f4d
__sfx__
000500001305015660156501264012640106201061000000000000000023600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b0201b0201b0201b0201b0401c0501e04021040260402b0402b0402a040190402405025060260601a0601506016060130600e0600b05008040060300503003020030200802010050290503a05000000
0001000034310283401d33012730107100e7200d7100d7100d7100c7100e7100f71012710147201b7301d7301f7302173024730277302a7302f73032730327302d7002c7002a50021500045000b5003d50000000
0001000006550045500355018500015001b50018500195001c5002d7002b70029700117002d500137002e5001c7002d7003370034500317001c7002c700327002a70000000000000000000000000000000000000
010500002571022710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b45030050000000000000000000000000000000000000000000000000000000037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000014710287202d730357003a7001c1001f10022100251002510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000187501c7501e75020750227502375024750257502675027750277502775027750287502875028750277502775026750257502475023750237502275021750207501f7501e7501d7501b75019750
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c00000c0531a0003b655130000c053000003b655000000c053000003b655000000c0530c0533b6550c0530c053000003b655000000c053000003b655000000c053000003b655000000c053000003b6553b655
001a00000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c000
001a00000e050134301a35017140104301100015700210000e05011430144301713013450013001c700207000e050134301a35017140104301570015700210000e05011440144401716012420195001c70020700
011a0000217300d02012550140202073015020175500c020217300c0200a5500c02017730080200a5500802020730080200d5501002017730130201755017020217301702014550150202173013020155500e030
010f00001c0331c0331800024000346151c03318000180001c0331c6051c03328605346352860528605286051c0331c0331c60024000346151c033240001c0331c0331c033180001c0333461524000240001c033
010f000015755150301575510005157551a7301f730157551505515730157551a0051a0551c0301f0302105500705177551705521705227051f7551a0302175500705177551705515705187051a0551c7301c045
000f00001c0551d0551e0551f055180051a00528055290552a0552b05500005370053405535055360553705500005000053405234052360053505235052360023605236052360023705237052370523705237052
000f00000c0550e0550f055100550e7051f705180551a0551b0551c055180052b70524055260552705528055327023070024052240522470226052260522870227052270522d7022805228052280522805228052
000f05001305515055160551705510605100051f0552105522055230551c0051c6052b0552d0552e0552f05530002346022b0522b052280022d0522d052240022e0522e052240022f0522f0522f0522f0522f052
001b0000017550875500000067550875501755000000675500000017550675500000087550175506755017000075507755000000475507755007550000004755000000075504755000000775500755047550d700
011000002d7352d0102d735280052d73532710377102d7352d0352d7102d7352600532035340103701039035247052f7352f0352d7053a705377353201039735307052f7352f0352d70530705320353471034025
__music__
03 0e0f4344
03 4c0b0d44
04 10111244
03 13424344
03 14424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 414b4344