pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

p = {
	x=64,
	y=64,
	speed=4,
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


-- variable intro --
txtintro = {"we are in the year 18, an inte","nse cold covered the region of"," vallis bona. but this is not ","random: the scouls have invade", "d the country. on their frozen"," planet, it was impossible for"," them to eat anything but ice."," a dilemma is imposed on human","s: give the scouls their best ","dish or die ..."}
txtintrotmp = sub(txtintro[1],1,1)
cptintro = 1
yintro = 30
cptline = 0
nbloop = 0
timeintro = 0



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
{37,14},
{60,14},
{70,14},
{93,1},
{10,30}
}
spawnmonster={{{10/8,5,"h"},{15/8,60/8,"h"}}
,{{}}
,{{56,4,"v"},{59,10,"h"},{60,8,"h"}}
,{{72,7,"h"},{78,11,"v"},{71,3,"v"},{74,2,"h"}}}
-- { tous les monstres du jeu { tous les monstres du level { 1 monstre

teleporteur={{4,11}}

------ fonctions initialisations ------

function _init()
  cartdata("v0")
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

function game_update()
  time_manager()
  move_actor()
  deplacement()
  touch_flag()
  anim_dir(direction)
  animation("")
  if(arret!=true) then make_particles(5) end
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
end

function menu_draw()
 cls()
 map(0,48,0,0,16,16)
 camera(0,0)
 print("press x to start",10,10,0)
 spr(p.sprite,45,35)
  if(dget(level)!=nil) then
    print("level "..level,10,18,0)
    print("best score : "..dget(level),10,25,0)
  else print("level "..level,10,18,0)
  end
  print("<-   ->",35,35)
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
	if(timeintro % 3 == 0) and (nbloop < 289) then
		nbloop += 1
		numsentence = get_sentence(nbloop)
		print(txtintrotmp, 0, yintro, 7)
		if(nbloop % 30 == 0) then --faire un retour à la ligne
			yintro += 7
		end
		txtintrotmp = sub(txtintro[numsentence], 1, nbloop%30+1) -- récupère 1 à 1 les 30 premiers caractère (nbloop%30)
		sfx(4)
	end
	if(nbloop >= 289) then
		print("press c to go to the menu", 1, 110,15)
	end
	if(btnp(4)) then --on affiche le menu quand le joueur appuie sur 'c'
		go_menu()
	end
end

function go_menu()
  _update=menu_update
  _draw= menu_draw
  actors={}
  music(1)
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
    if level < 10 and dget("unlock")>level then
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
  -- move the mouse left/right
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
  -- move the mouse up/down
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
  if hitwall(p.x,p.y,4) then direction ="g"
  elseif hitwall(p.x,p.y,5) then direction ="h"
  elseif hitwall(p.x,p.y,6) then direction ="d"
  elseif hitwall(p.x,p.y,7) then direction ="b"
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
	if(nbloop < 300) then
		return 10
	end

end


-- chronometre :

function time_manager()
	ctime.ms += 1/30
	if (ctime.ms >= 1) then
		ctime.ms=0
		ctime.s+=1
		if (ctime.s >=60) then
			ctime.s=0
			ctime.m+=1
		end
	end
end

function reset_timer()
	ctime.s=0
	ctime.m=0
	ctime.ms=0
end

---------------------------------------------





__gfx__
000000000000000000000000c11cc11cc889988c000cc000000cc000000000000000000000000000bb333333344f4f430bbbbb00dddd3ddd555995559ffffff9
00000000000000000000000011cccc118899998800cccc00000cc00000000c0000c0000000000000333bb353444444440b333b00dd3d3d3d55999955ffffffff
0000000000000000000000001cc66cc1899aa9980cccccc0000cc00000000cc00cc000000000000035533bb344f444f40bb33b00dd83338d5999999544444444
0000000000000000000000001c6666c189aaaa98000cc000000cc000cccccccccccccccc00000000b3333b33f444f444bbb3bbbbd83383389999999999999999
0000000000000000000000001c6666c189aaaa98000cc000000cc000cccccccccccccccc0000000053333b3333333333b3bbb33bd88888879999999988888888
0000000000000000000000001cc66cc1899aa998000cc0000cccccc000000cc00cc000000000000035bb3b334444f444b33b333bd888888859999995bbbbbbbb
00000000000000000000000011cccc1188999988000cc00000cccc0000000c0000c000000000000035333b3b4f44444fbb3b33bbd888888855999955ffffffff
000000000000000000000000c11cc11cc889988c000cc000000cc00000000000000000000000000033335333344f44430bbbbbb0dd88888d555995559ffffff9
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
c44544544454455545554555454555c4e4e4e4e4e4f5e4d40616061606160616160607170717d4e4e4e4e5f5f5f5c42636263626273727372737273736c4e4e4
e4e5f5f5e4c44656564647574656574757464656c4e4e5f5f5f4f4e4c567776777667667776777677767776777677766766777677767776777667667776777c5
c54445554555445444544454445454c4e4e4e5e4f5f5e4d40717071707170706160717060616d4e4e4e4e4e4f5e4c42737273727263626362636263637c4e4e4
e4e4e4f5e4c44757574746564757465656474757c4e4e4e4f5e4e4e4c566766666677766766676667666766676666667776676667666766666677766766676c5
c54544544454455545554555455555c4e4e4e5e5f5e4e4d40616061606160607170707070717d4e4e4e4e5e5e5e5c42737273726363727372737272636c4e4e4
f4f4e4e4e4c44656564647574656475757464757c4e4e4e4e4e4e4e4c566766676667666766676667666766676667666766676667666766676667666766676c5
c54445554454445444544454445454c4e4e4e4e5f5f5e4d40717071707170706160606160616d4e4e4e4e5e4f5f5c42636263627372636263626362737c4e4e4
e4e4e4e4e4c44757574746564757465646475756c4e4e4e4e4e400e4c567776777677767776676677766766777677767776777667667776777677767776676c5
c54555445455455545554555455555c4e4e4e4e4e4f5e4d40616061606160616061607170717d4e4e4e4e5e5f5e4c42636273726362636273727373636c4e4e4
e4e4e4e4e4c44656465647574757475747574757c4e4e5e5e5e5f4f4c566766777667666766777667667776676677766766676677766766777667666766777c5
c44454455544544454445444544454c4e4e4e5e5e5e5e4d40616061606160616061607170616d4e4e4e4e4e5f5f5c42636363727372737263626362636c5e4e4
e4e4e4e4e4c44656465646465646564646564656c4e4e5e4f5f5e4f4c567776676677767777667677776676777667667776777766767776676677767777667c5
c44555455545554555455545554555c4e4e4e5e4f5f5e4d40717071707170717071707170717d4e4e4e4e4e4e4f5c42737373727372737273727372737c5e4e4
e4e4e4e4e4c44757475747475747574747574757c4e4e5e5f5e4e4f4c567776777667677677777776777776777677766767767777767776777667677677777c5
c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e4e4e5e5f5e4e4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4e4e4e4e4e4e4e4c4c4c4d4d4d4d5c4c4d4c5c5c5d5c5c5e4e4
e4e4e4e4e4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e4e4e5f5f5f4f4c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5
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
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e4e4c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5e4e4e4e4e4e4e4c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5e4e5
e4f5f5e4f4c4c5c5c5c5c5c4c5c4c4c5c4c5c4c5c5e4e4e4e4f5e4e4d5d5d4d4d4d4d4d5d5d5d5d4d5d4d4c4c4c4d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5
c42626c4c43626c4263626d426d4d4d4e4e4e5e5e5e5e4c5b096869686968696869686968696c5e4e4e4e5e5e4e4c5e0b6a6b6a6b6a6b6a6b6a6b6a6b6c5e4e5
e5f5e4e4f4c4d0d6d6c6d6c6d6c6c6d6c6d6c6d6c5e4e4e4e4e4e4e4d5f024242495a53646157435451727b6c6948674841574846537475767576737475767d5
2634352736252536253535262426d4d4e4e4e5e4f5f5e4c58797879787978696869686968696c5e4e4e5e5e5e5e4c5a7b7a7b7a7b7a7a6a7b7a7b7a7b7c5e4e4
e5f5f5f4f4d5c6d6d7c7d7c7d7c7c7d7c7d7c7d7c5e4e4e4e4e4e4e4d53434242696a637471675364676867484946675851675162615748465846515748465d5
2426263635372725372436242527d427e4e4e4e5e5e4e4c58686968686968797879787978797c5e4e4e5e4f5f5e4c5a6b6a6b6a6b6a6a7b7a7b7a7a6b6c5e4e5
e5e5e5f4f4d5c7d7c6d6d6c6d6d6c6d6c6d6c6d6d4e5e5e5e5e5f4f4c524352527b6c694a43545364656667585951574846595a53616751626162616751626d5
25352636343435353734273654262744e4e4e5e5e5e5e4c58787978787978696869686968696c5e4e4e5e5f5e4e4c5a7b7a7b7a7b7a7b7a7b7a7b7a7b7c5e4e5
e4f5f5e4f4d5c6d6c7d7d7c7d7d7c7d7c7c6c6d6d4e5e5e4f5f5e4f4c536467686748415748465374757677686961675162696a63735451727172735451727d5
d5272736346363343735373645442644e4e4e5e4f5f5f5c58686969687978797879787868797c5e4e4e4e5e5e4e4c5a6b6a6b6a6b6a6b6a6b6a6b6a6b6c5e4e5
e5f5e4e4f4d4c7d7c6d6c6c6d6c6d6d6c6c7c7d7d4e5e5e5f5e4e4f4d5364656667585167516261574846595a53635451727b6c69436467686768636467686d5
d5252536346363253635262655275454e4e4e5e5f5e4e4c58787979786968696869686878696c5e4e4e5e5e5e5e4c5a7b7a7b7a7b7a7b7a7b7a7b7a7b7c5e4e4
e5f5f5f4f4d4c6d6c7d7c7c7d7c7c6d6c6d6c6d6c5e5e4e5f5f5f4f4c53747571574846595a5361675162696a6373646768674849436465666566636465666d5
d53636c437d4d426c526c53644372655e4e4e4e5f5f5e4c58696969687978797879787868797c5e4e4e5e4f5f5e4c5a6b6a6b6a6b6a6b6a6b6a6b6a6b6c5e4e5
e5e5e5f4f4c4c7d7d6c6d6d7c7d7c7d7c7d7c7d7d4e4e4e4e4f5e4e4d51574841675162696a63735451727b6c6943646566675859537475767576737475767c4
c42626c4c4d4d4d4c5c5c5d526c5c537e4e4e4e4e4f5e4c58797979786968696868696878696c5e4e4e5e5f5e4e4c5a7b7a7b7a7b7a6b6a6b6a7b7a7b7c5e4e5
e4f5f5e4f4c4c6d6c6d6d7d6c6d6c6d6c6d6c6d6d4e4e4e4e4e4e4e4c516751635451727b6c694364676867484943646566675859537475767a53616751626c4
c4a4b426c4d4d426c5c5c5d5d5c5c5c5e4e4e4e5e5e4e4c58686968696869686968797868797c5e4e4e4e5f5f5e4c5a6b6a6b6a6b6a7b7a7b7a6b6a6b6c5e4e5
e5f5e4e4f4c4c7d7c7d7c7d7c7d7c7d7c7d7c7d7d5e4e5e5e5e5f4f4c586748415748465374757678674841574846537475767861675162696a63735451727c5
c43636b536d42646263636d5d53636c5e4e4e5e5e5e5e4c58787978797879787978696878696c5e4e4e4e4e4f5e4c5a7b7a7b7a6b6a6b6a6b6a6b6a7b7c5e4e4
e5f5f5f4f4c4c6d6c6d6c6d6c6d6c6d6c6d6c6d6d5e4e5e4f5f5e4f4c5667585167516261574846566758516751626157484656635451727b6c69436467686c4
c436363636d4d4261404053636646536e4e4e5e4f5f5e4c58686968696869686968797878797c5e4e4e4e4e4e4e4c5a6b6a6b6a7b7a7b7a7b7a7b7a6b6c5e4e4
e4e4f5e4e4c4c7d7c7d7c7d7c7d7c7d7c7d7c7d7d5e4e5e5f5e4e4f4c51574846595a536167516261574846595a53616751626153646768674849436465666c4
c4a5a4368436364705272704643636d4e4e4e5e5f5e4e4c58787978797879787978786968696c5e4e4e4e4e4e4e4c5a7b7b6b6a6b6a6b6a6b6a6b6a6b6c5e4e5
e5e5e5f4f4d4c6d6c6d6c6d6c6d6c6d6c6d6c6d6d5e4e5e5e5e5f4f4c51675162696a637354517271675162696a63735451727163646566675859537475767c4
c43636a48536364615272705656436d4e4e4e4e5f5f5e4c58696868696869686968687869697c5e4e4e4e4e4e4e4c5a6b6a6b6a7b7a7b7a7b7a7b7a7b7c5e4e5
e4f5f5e4f4d4c7d7c7d7c7d7c7d7c7d7c7d7c7d7d5e4e5e4f5f5e4f4c535451727b6c6943646768635451727b6c694364676863535451727b6c69436467686c5
b53636a48436365715272704753636d4e4e4e4e4e4f5e4c58696869686968696869686968696c5e4e4e4e4e4e4e4c5a7b7a6b6a6b6a6b6a6b6a6b6a6b6c5e4e5
e5f5e4e4f4c4c6d6c6c6d6c6d6c6d6c6d6c6d6d6d5e4e5e5f5e4e4f4d436467686748494364656663646768674849436465666363646768674849436465666c5
37a4a537278585461414142736747436e4e4e4e4e4e4e4c58797879787978797879787978797c5e4e4e4e4e4e4e4c5a7b7a7b7a7b7a7b7a7b7a7b7a7b7c5e4e4
e5f5f5f4f4c4c7d7c7c7d7c7d7c7d7c7d7c7d7d7d5e4e4e5f5f5f4f4d436465666758595374757673646566675859537475767363646566675859537475767d4
c43737d4d4272736272727d4d43636d4e4e4e4e4e4e4e4c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5e4e4e4e4e4e4e4c5c5c5c5c5c5c5c5c5c5c5c4c4c5c5c5e4e4
e4e4f5e4e4c4c4d5d5c4c4d4d4d4d4c5c5c4c4c4c5e4e4e4e4f5e4e4d4d5d5d5d4d4d4d5d5d5d5d5c5c5c5c5c5c5c5c5d5d5c5d5d5d5d5d4d5d5d4d5d5d5d4d4
__label__
77757775055577757770777677555005055550655550556755505567555055675000055605555065500005560555506550000556055550650555506555505567
55767076055670755575557507567055555600065500556655005566550055665505555555560006550555555556000655055555555600065556000655005566
77707570056677767775677507660056576065000000565600005656000056567005655557606500700565555760650070056555576065005760650000005656
75607575000070700070007507000000556055550650565506505655065056550000005555605555000000555560555500000055556055555560555506505655
77707776575577767775777077755056500055560550055005500550055005500055500050005556005550005000555600555000500055565000555605500550
00550555055500565055555505550056005505550555000005550000055500005055555500550555505555550055055550555555005505550055055505550000
05550555675500555055555667550055055505550555006705550067055500675055555605550555505555560555055550555556055505550555055505550067
05550060665500555000056666550055055500600056006600560066005600665000056605550060500005660555006050000566055500600555006000560066
5550556700000000cccccccccccccccccccccccccccccccccc6666cc0555500505555005cccccccccc6ccccccccccccccc6ccccccccccccccc6ccccc55505567
5500556600580000ccccccccccccccccccccccccccccccccc666ffcc0556705505567055ccccccccc6ccccccccccccccc6ccccccccccccccc6cccccc55005566
0000565600588000cccccc7ccccccc6cccc7ccccccc7cccc7c6fcfcc0566005605660056ccc7cccc7cccccccccc7cccc7cccccccccc7cccc7ccccccc00005656
0650565500588800ccccc7cccc6cc7cccc7ccccccc7ccccccc6ffffc0000000000000000cc7ccccccccccccccc7ccccccccccccccc7ccccccccccccc06505655
0550055000588000cccc7cccc6cc7cccc7ccccccc7ccccccccf6666c5555505655555056c7cccccccccccc6cc7cccccccccccc6cc7cccccccccccc6c05500550
0555000000580000ccc6cccc6ccccccccccccccccccccccccfbbbbfc0555005605550056ccccccccccccc6ccccccccccccccc6ccccccccccccccc6cc05550000
0555006700500000ccccccccccccccccccccccccccccccccfc2222cf6755005567550055cccccccccccc7ccccccccccccccc7ccccccccccccccc7ccc05550067
0056006605555550cccccccccccccccccccccccccccccccccc7cc7cc6655005566550055cccccccccccccccccccccccccccccccccccccccccccccccc00560066
05555065555055675550556755505567cccccccccccccccccccccccc0555500505555005cccccccccccccccccccccccccc6ccccccccccccccc6ccccc05555005
55560006550055665500556655005566cccccccccccccccccccccccc0556705505567055ccccccccccccccccccccccccc6ccccccccccccccc6cccccc05567055
57606500000056560000565600005656cccccc6ccccccc6ccccccc7c0566005605660056cccccc6ccccccc7cccc7cccc7cccccccccc7cccc7ccccccc05660056
55605555065056550650565506505655cc6cc7cccc6cc7ccccccc7cc0000000000000000cc6cc7ccccccc7cccc7ccccccccccccccc7ccccccccccccc00000000
50005556055005500550055005500550c6cc7cccc6cc7ccccccc7ccc5555505655555056c6cc7ccccccc7cccc7cccccccccccc6cc7cccccccccccc6c55555056
005505550555000005550000055500006ccccccc6cccccccccc6cccc05550056055500566cccccccccc6ccccccccccccccccc6ccccccccccccccc6cc05550056
05550555055500670555006705550067cccccccccccccccccccccccc6755005567550055cccccccccccccccccccccccccccc7ccccccccccccccc7ccc67550055
05550060005600660056006600560066cccccccccccccccccccccccc6655005566550055cccccccccccccccccccccccccccccccccccccccccccccccc66550055
50000556cccccccccc6ccccccccccccccc6ccccccccccccccccccccccc6ccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccccc55505567
55055555ccccccccc6ccccccccccccccc6ccccccccccccccccccccccc6ccccccccccccccccccccccc6cccccccccccccccccccccccccccccccccccccc55005566
70056555ccc7cccc7cccccccccc7cccc7ccccccccccccc7cccc7cccc7cccccccccc7ccccccc7cccc7ccccccccccccc6ccccccc7ccccccc6ccccccc7c00005656
00000055cc7ccccccccccccccc7cccccccccccccccccc7cccc7ccccccccccccccc7ccccccc7ccccccccccccccc6cc7ccccccc7cccc6cc7ccccccc7cc06505655
00555000c7cccccccccccc6cc7cccccccccccc6ccccc7cccc7cccccccccccc6cc7ccccccc7cccccccccccc6cc6cc7ccccccc7cccc6cc7ccccccc7ccc05500550
50555555ccccccccccccc6ccccccccccccccc6ccccc6ccccccccccccccccc6ccccccccccccccccccccccc6cc6cccccccccc6cccc6cccccccccc6cccc05550000
50555556cccccccccccc7ccccccccccccccc7ccccccccccccccccccccccc7ccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccc05550067
50000566cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00560066
50000556cccccccccccccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccccccccccccc5000055605555005cccccccccc6ccccc55505567
55055555ccccccccccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccccccccccccccccc5505555505567055ccccccccc6cccccc55005566
70056555cccccc6ccccccc7ccccccc6ccccccc7c7ccccccccccccc6ccccccc7ccccccc6ccccccc6ccccccc7c7005655505660056ccc7cccc7ccccccc00005656
00000055cc6cc7ccccccc7cccc6cc7ccccccc7cccccccccccc6cc7ccccccc7cccc6cc7cccc6cc7ccccccc7cc0000005500000000cc7ccccccccccccc06505655
00555000c6cc7ccccccc7cccc6cc7ccccccc7ccccccccc6cc6cc7ccccccc7cccc6cc7cccc6cc7ccccccc7ccc0055500055555056c7cccccccccccc6c05500550
505555556cccccccccc6cccc6cccccccccc6ccccccccc6cc6cccccccccc6cccc6ccccccc6cccccccccc6cccc5055555505550056ccccccccccccc6cc05550000
50555556cccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc5055555667550055cccccccccccc7ccc05550067
50000566cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5000056666550055cccccccccccccccc00560066
05555005cccccccccc6ccccccccccccccc6ccccccccccccccccccccccc6ccccccccccccccccccccccc6ccccc55505567cccccccccccccccccccccccc55505567
05567055ccccccccc6ccccccccccccccc6ccccccccccccccccccccccc6cccccc111111ccccccccccc6cccccc55005566cccccccccccccccccccccccc55005566
05660056ccc7cccc7cccccccccc7cccc7ccccccccccccc7cccc7cccc7cccccc111b11b1cccc7cccc7ccccccc00005656ccc7cccccccccc6ccccccc7c00005656
00000000cc7ccccccccccccccc7cccccccccccccccccc7cccc7cccccccccccc11133133ccc7ccccccccccccc06505655cc7ccccccc6cc7ccccccc7cc06505655
55555056c7cccccccccccc6cc7cccccccccccc6ccccc7cccc7cccccccccccc611111111cc7cccccccccccc6c05500550c7ccccccc6cc7ccccccc7ccc05500550
05550056ccccccccccccc6ccccccccccccccc6ccccc6ccccccccccccccccc6ccc1111cccccccccccccccc6cc05550000cccccccc6cccccccccc6cccc05550000
67550055cccccccccccc7ccccccccccccccc7ccccccccccccccccccccccc7ccc1cccc1cccccccccccccc7ccc05550067cccccccccccccccccccccccc05550067
66550055ccccccccccccccccccccccccccccccccccccccccccccccccccccccc1cccccc1ccccccccccccccccc00560066cccccccccccccccccccccccc00560066
05555005cccccccccccccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccccccccccccc05555065cccccccccccccccccc6ccccc05555065
05567055ccccccccccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccccccccccccccccc55560006ccccccccccccccccc6cccccc55560006
05660056cccccc6ccccccc7ccccccc6ccccccc7c7ccccccccccccc6ccccccc7ccccccc6ccccccc6ccccccc7c57606500cccccc6cccc7cccc7ccccccc57606500
00000000cc6cc7ccccccc7cccc6cc7ccccccc7cccccccccccc6cc7ccccccc7cccc6cc7cccc6cc7ccccccc7cc55605555cc6cc7cccc7ccccccccccccc55605555
55555056c6cc7ccccccc7cccc6cc7ccccccc7ccccccccc6cc6cc7ccccccc7cccc6cc7cccc6cc7ccccccc7ccc50005556c6cc7cccc7cccccccccccc6c50005556
055500566cccccccccc6cccc6cccccccccc6ccccccccc6cc6cccccccccc6cccc6ccccccc6cccccccccc6cccc005505556cccccccccccccccccccc6cc00550555
67550055cccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc05550555cccccccccccccccccccc7ccc05550555
66550055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc05550060cccccccccccccccccccccccc05550060
55505567cccccccccc6ccccc05555065cccccccccccccccccccccccccc6ccccccccccccccc6ccccccc6ccccc05555065cccccccccccccccccccccccc05555065
55005566ccccccccc6cccccc55560006ccccccccccccccccccccccccc6ccccccccccccccc6ccccccc6cccccc55560006cccccccccccccccccccccccc55560006
00005656ccc7cccc7ccccccc57606500cccccc6ccccccc7cccc7cccc7cccccccccc7cccc7ccccccc7ccccccc57606500ccc7cccccccccc6ccccccc7c57606500
06505655cc7ccccccccccccc55605555cc6cc7ccccccc7cccc7ccccccccccccccc7ccccccccccccccccccccc55605555cc7ccccccc6cc7ccccccc7cc55605555
05500550c7cccccccccccc6c50005556c6cc7ccccccc7cccc7cccccccccccc6cc7cccccccccccc6ccccccc6c50005556c7ccccccc6cc7ccccccc7ccc50005556
05550000ccccccc1111116cc005505556cccccccccc6ccccccccccccccccc6ccccccccccccccc6ccccccc6cc00550555cccccccc6cccccccccc6cccc00550555
05550067cccccc111b11b1cc05550555cccccccccccccccccccccccccccc7ccccccccccccccc7ccccccc7ccc05550555cccccccccccccccccccccccc05550555
00560066cccccc11133133cc05550060cccccccccccccccccccccccccccccccccccccccccccccccccccccccc05550060cccccccccccccccccccccccc05550060
05555065cccccc11111111cc05555005cccccccccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccccccccccccccccccccc05555065
55560006cccccccc1111cccc05567055ccccccccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccc6cccccccccccccccccccccc55560006
57606500cccccc61cccc1c7c05660056ccc7cccc7ccccccccccccc6cccc7cccccccccc6ccccccc7ccccccc7cccc7cccc7ccccccccccccc7ccccccc7c57606500
55605555cc6cc71cccccc1cc00000000cc7ccccccccccccccc6cc7cccc7ccccccc6cc7ccccccc7ccccccc7cccc7cccccccccccccccccc7ccccccc7cc55605555
50005556c6cc7ccccccc7ccc55555056c7cccccccccccc6cc6cc7cccc7ccccccc6cc7ccccccc7ccccccc7cccc7cccccccccccc6ccccc7ccccccc7ccc50005556
005505556cccccccccc6cccc05550056ccccccccccccc6cc6ccccccccccccccc6cccccccccc6ccccccc6ccccccccccccccccc6ccccc6ccccccc6cccc00550555
05550555cccccccccccccccc67550055cccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccc05550555
05550060cccccccccccccccc66550055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc05550060
05555065cccccccccccccccccc6ccccccccccccccccccccccccccccccccccccccccccccc05555005cccccccccccccccccccccccc555055670555500550000556
55560006ccccccccccccccccc6cccccccccccccccccccccccccccccccccccccccccccccc05567055cccccccccccccccccccccccc550055660556705555055555
57606500ccc7ccccccc7cccc7ccccccccccccc6ccccccc7ccccccc6ccccccc6ccccccc7c05660056ccc7cccccccccc6ccccccc7c000056560566005670056555
55605555cc7ccccccc7ccccccccccccccc6cc7ccccccc7cccc6cc7cccc6cc7ccccccc7cc00000000cc7ccccccc6cc7ccccccc7cc065056550000000000000055
50005556c7ccccccc7cccccccccccc6cc6cc7ccccccc7cccc6cc7cccc6cc7ccccccc7ccc55555056c7ccccccc6cc7ccccccc7ccc055005505555505600555000
00550555ccccccccccccccccccccc6cc6cccccccccc6cccc6ccccccc6cccccccccc6cccc05550056cccccccc6cccccccccc6cccc055500000555005650555555
05550555cccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc67550055cccccccccccccccccccccccc055500676755005550555556
05550060cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66550055cccccccccccccccccccccccc005600666655005550000566
50000556cccccccccccccccccc6ccccccc6ccccc55505567555055675000055650000556bb333333cccccccccccccccccccccccccccccccc0889988055505567
55055555ccccccccccccccccc6ccccccc6cccccc55005566550055665505555555055555333bb353cccccccccccccccccccccccccccccccc8899998855005566
70056555cccccc6cccc7cccc7ccccccc7ccccccc0000565600005656700565557005655535533bb3cccccc6ccccccc6ccccccc7cccc7cccc899aa99800005656
00000055cc6cc7cccc7ccccccccccccccccccccc06505655065056550000005500000055b3333b33cc6cc7cccc6cc7ccccccc7cccc7ccccc89aaaa9806505655
00555000c6cc7cccc7cccccccccccc6ccccccc6c0550055005500550005550000055500053333b33c6cc7cccc6cc7ccccccc7cccc7cccccc89aaaa9805500550
505555556cccccccccccccccccccc6ccccccc6cc0555000005550000505555555055555535bb3b336ccccccc6cccccccccc6cccccccccccc899aa99805550000
50555556cccccccccccccccccccc7ccccccc7ccc0555006705550067505555565055555635333b3bcccccccccccccccccccccccccccccccc8899998805550067
50000566cccccccccccccccccccccccccccccccc0056006600560066500005665000056633335333cccccccccccccccccccccccccccccccc0889988000560066
05555005cccccccccc6ccccccccccccc0cc11cc0cccccccccc6ccccccccccccccc6ccccccccccccccccccccccccccccccc6ccccccccccccccc6ccccc55505567
05567055ccccccccc6cccccccccccccccc1111ccccccccccc6ccccccccccccccc6ccccccccccccccccccccccccccccccc6ccccccccccccccc6cccccc55005566
05660056ccc7cccc7ccccccccccccc7cc116611cccc7cccc7cccccccccc7cccc7cccccccccc7cccccccccc6ccccccc7c7cccccccccc7cccc7ccccccc00005656
00000000cc7cccccccccccccccccc7ccc166661ccc7ccccccccccccccc7ccccccccccccccc7ccccccc6cc7ccccccc7cccccccccccc7ccccccccccccc06505655
55555056c7cccccccccccc6ccccc7cccc166661cc7cccccccccccc6cc7cccccccccccc6cc7ccccccc6cc7ccccccc7ccccccccc6cc7cccccccccccc6c05500550
05550056ccccccccccccc6ccccc6ccccc116611cccccccccccccc6ccccccccccccccc6cccccccccc6cccccccccc6ccccccccc6ccccccccccccccc6cc05550000
67550055cccccccccccc7ccccccccccccc1111cccccccccccccc7ccccccccccccccc7ccccccccccccccccccccccccccccccc7ccccccccccccccc7ccc05550067
66550055cccccccccccccccccccccccc0cc11cc0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00560066
55505567cccccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc50000556
55005566ccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55055555
00005656cccccc6ccccccc7cccc7cccc7ccccccccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7c70056555
06505655cc6cc7ccccccc7cccc7ccccccccccccccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cc00000055
05500550c6cc7ccccccc7cccc7cccccccccccc6cc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7ccc00555000
055500006cccccccccc6ccccccccccccccccc6cc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc50555555
05550067cccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc50555556
00560066cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc50000566
55505567cccccccccc6ccccccccccccccccccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccc55505567
55005566ccccccccc6ccccccccccccccccccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccccccccccccc6cccccc55005566
00005656ccc7cccc7ccccccccccccc6ccccccc7cccc7cccc7cccccccccc7cccc7cccccccccc7cccc7cccccccccc7cccc7cccccccccc7cccc7ccccccc00005656
06505655cc7ccccccccccccccc6cc7ccccccc7cccc7ccccccccccccccc7ccccccccccccccc7ccccccccccccccc7ccccccccccccccc7ccccccccccccc06505655
05500550c7cccccccccccc6cc6cc7ccccccc7cccc7cccccccccccc6cc7cccccccccccc6cc7cccccccccccc6cc7cccccccccccc6cc7cccccccccccc6c05500550
05550000ccccccccccccc6cc6cccccccccc6ccccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccccccccccccc6ccccccccccccccc6cc05550000
05550067cccccccccccc7ccccccccccccccccccccccccccccccc7ccccccccccccccc7ccccccccccccccc7ccccccccccccccc7ccccccccccccccc7ccc05550067
00560066cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00560066
05555005cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc05555065
05567055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55560006
05660056cccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7ccccccc6ccccccc7c57606500
00000000cc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cc55605555
55555056c6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7cccc6cc7ccccccc7ccc50005556
055500566cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc6cccccccccc6cccc00550555
67550055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc05550555
66550055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc05550060
05555005055550050555506505555005500005565550556705555065055550650555500555505567555055670555506550000556555055675550556705555065
05567055055670555556000605567055550555555500556655560006555600060556705555005566550055665556000655055555550055665500556655560006
05660056056600565760650005660056700565550000565657606500576065000566005600005656000056565760650070056555000056560000565657606500
00000000000000005560555500000000000000550650565555605555556055550000000006505655065056555560555500000055065056550650565555605555
55555056555550565000555655555056005550000550055050005556500055565555505605500550055005505000555600555000055005500550055050005556
05550056055500560055055505550056505555550555000000550555005505550555005605550000055500000055055550555555055500000555000000550555
67550055675500550555055567550055505555560555006705550555055505556755005505550067055500670555055550555556055500670555006705550555
66550055665500550555006066550055500005660056006605550060055500606655005500560066005600660555006050000566005600660056006605550060

__gff__
0200020004208040100100020202020200000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020200000000000000000000000001010000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4c4c4c4c4c4c4c4d4c4c4c4c4c4c4d4c4e4e4e4e4e4e4e5c4d5d4d4d4c5c5c5d4d5c5c4d5c5c5c4e5e5e5e5e4f4f4d4c5c5c5c5c5c5c5c5c4c5c5c4c5d4d5e5e5e5e4f4f4e4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e5e5e5e5e4f4f4c4c4c4c4c4c4d4d5c5c5c4c4c4c5c5c5c5c5c5c5c5c4c4c5d4d5d5d5d5d4c4c4c4c4c4c
4d0241504151514c4c5151514141414d4e5e5e5e5e4f4f5d374c5c42435c5c424342434243434d4e5e4e5f5f4e4f5c38474647464746474647464746475c5e4e5f5f4e4f4f4c4a4c4a4b4a4b4a4b4a4b4a4b4a4b4c4e5e4e5f5f4e4f4c484948494849484948494849484948494849484948494849484948494849484948494c
4c4d4d4d5051515c5c5051404140415c4e5e4e5f5f4e4f4c424d525253524c525352534d5d535d4e5e5e5f4e4e4f4c56575657565756575657565756575d5e5e5f4e4e4f4f4c5a5b5a4c5a5b5a5b5a5b5a5b4c5b4c4e5e5e5f4e4e4f4c585958595859585958595859585958595859585958595859585958595859585958594c
5d40414041514041404041505150514d4e5e5e5f4e4e4f4d524c4242434243424342434243535c4e4e5e5f5f4f4f5c46474647464746474647464746475c4e5e5f5f4f4f4f4c4a4b4a4b4a4b4c4b4a4b4a4b4a4b4c4e4e5e5f5f4f4f4c484948494849484948494849484948494849484948494849484948494849484948494c
5d505150514150515050515d5c40414d4e4e5e5f5f4f4f5c424c5c5253524343424243524c5c4d4e4e4e4e5f4e4e5c56575657565756575657565756575c4e4e4e5f4e4e4f4c5c5b4a5b5a5b5a5b5a5b5a5b5a5b4c4e4e4e4e5f4e4e4c585958595859585958595859585958595859585958595859585958595859585958594c
5c404140415140414040414d4050514d4e4e4e4e5f4e4e4c52535c435c4243424352534242435c4e4e5e5f5f4f4f5d46474647464746474647464746475d4e4e4e4e5f4e4e4c4a4b4a5c4a4b4a4b4a4b4c4b4a4b4c4e5e4e5f5f4e4f4c484948494849484948494849484948494849484948494849484948494849484948494c
5c505150514150515050514c5040414c4e5e5e5f4e4e4f4d52535c5342435352535c424352534c4e4e4e4e5f4e4e5c56575657565756575657565756575c4e4e4e4e5f4e4e4c5a5b5a5b5a5b5a5b5a5b5a5b5a5b4c4e5e5e5e5e4f4f4c585958595859585958595859585958595859585958595859585958595859585958594c
4d40414c505140414041414c4050514c5e4e5e5f5f4f4f4c434d4243524c42434243525343435c4e5e5e5e5e4f4f5c46474647464746474647464746475d4e5e5e5f4e4e4f4c4c4b4a4b4a4b4a4b4a4b4a4b4a4b4c4e5e4e5f5f4e4f4c484948494849484948494849484948494849484948494849484948494849484948494c
4c50515c40415040505151404151514c5e4e4e4e5f4e4e4d42434353525352535253525243535d4e5e4e5f5f4e4f4c56575657565756575657565756574c4e4e5e5f5f4f4f4c5a5b5a5b5a5b4c395a5b5a5b5a4c4c4e5e5e5f4e4e4f4c585958595859585958595859585958595859585958595859585958595859585958594c
4c40404150515050515c4050514d5c5d5e5e5f4e4e4f4e5c52535342435343425342435c43434d4e5e5e5f4e4e4f4d46474647464746474647464746474d4e4e4e4e5f4e4e4c4a4b4a4b4a4b4a4b4a4c4a4b4a4c4c4e4e5e5f5f4f4f4c484948494849484948494849484948494849484948494849484948494849484948494c
5d504041414d4d5d5d0a50505140044d4e5e5f5f4f4f4e4d5d5c4352534243525352535253534c4e4e5e5f5f4f4f5d56575657565756575657565756575c5e5e5e5e4f4f4e4c5a5b4c5b5a5b5a5b5a5b5a5b5a5b4c4e4e4e4e5f4e4e4c585958595859585958595859585958595859585958595859585958595859585958594c
5c40415103404140414050514140414d4e4e4e5f4e4e4e4d524342434342434243424c4242434d4e4e4e4e5f4e4e5c46474647464746474647464746475c5e4e5f5f4e4f4e4c4a4b4a4b4c4c4a4b4a4b4a4b4a4b4c4e5e4e5f5f4e4f4c484948494849484948494849484948494849484948494849484948494849484948494c
4d50514041505150515051505150515d4e4e4e4e4e4e4e4d525352535352535c5352535252535c4e5e5e5e5e4f4f4c56575657565756575657565756574c5e5e5f4e4e4f4e4c5a5b4c5b5a5b5a5b5a5b4c5b5a4b4c4e5e5e5f4e4e4f4c585958595859585958595859585958595859585958595859585958595859585958594c
4d40415051404140414041404140414d4e5e5e5e5e4f4f4c42435c5d424343424243424342434c4e5e4e5f5f4e4f5d46474647464746474647464746475c4e5e5f5f4f4f4f4c4a4b4a4b4a4b4a4b4a4b4a4b4b4c4d4f4e5e5f5f4f4f4c484948494849484948494849484948494849484948494849484948494849484948494c
5c50515051505150515051505150514c4e5e4e5f5f4e4f4c525343535253534c52535253520a5d4e5e5e5f4e4e4f5c56575657565756575657565756574d4e4e4e5f4e4e4f4c5a5b5a5b5a4c5a5b4c5b5a5a5a5a4d4e4e4e4e5f4e4e4c585958595859585958595859585958595859585958595859585958595859585958594c
5c5c4c5c5d4d4c4c5c4d4d4c5d4d4d4c4e5e5e5f4e4e4f5c4c5c4d5c5c4c5c5c4d5d5c4c5d4d5c5e4e5e5f5f4f4f5c4c5d5c4c5c5c4c5d5c4c5c5c4d5c5d4e5e5e5f4e4e4f4c4c4c4c4c4c4c4c4c4c4c4c4d4d4d4d4e5e5e5e5e4f4f4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c
4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5f5f4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e4e4e4e5f5e5e5e5e4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e5e5e4f4f5e5e5e5e4f4f4e4e4e4e4e4f4e5e5f5f4f5e4e5f5f4e4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e
5e4e4e5e4f4f4f5e5e5e5e4f5e5e5e5e4f4e4e4e5f4e4e4f5e5e5e5e4f4f4e5e5e5e5e4f4f5e5e5e5e5f4e4e5e4e5f5f4e4f5e5e5e5e5e5e5e5e4f4f5e4f4f5e4e5f5f4e4f5e4e5f5f4e4f5e5e5e5e4f4f4e4e4e5e5e5e5e5f4e4e4f5e4e4e5e5e5e5e4f5e5e5e5e4f4f5e5e5e4f4f4e5e5e5e5e4f4f4e5e5e5e5e5e5e5e4f4f
5e4e4e4e4e4f4f5e4e5f5f4e5e4e5f5f4e4f5e4e5f5f4e4f5e4e5f5f4e4f5e5e5e5e4f4f4f5e4e4e5e5f5f4f5e5e5f4e4e4f5e4e5f5f5e4e5f5f4e4f5f4e4f5e5e5f4e4e4f5e5e5f4e4e4f5e4e5f5f4e4f5e5e5e5e4e4e5e5f5f4f4f4e4e4e5e4e5f5f4e5e4e5f5f4e4f4e5f5f4e4f4e5e4e5f5f4e4f4e5e4e5e5e4e5f5f4e4f
5e5e5f4e4e4f4f5e5e5f4e4e5e5e5f4e4e4f5e5e5f4e4e4f5e5e5f4e4e4f5e4e5f5f4e4f4f5e5e4e4e4e5f4e4e5e5f5f4f4f5e5e5f4e5e5e5f4e4e4f4e4e4f4e5e5f5f4f4f4e5e5f5f4f4f5e5e5f4e4e4f5e4e5f5e5e4e4e4e5f4e4e4e4e4e5e5e5f4e4e5e5e5f4e4e4f5e5f4e4e4f4e5e5e5f4e4e4f4e5e5e5e5e5e5f4e4e4f
4e5e5f5f4f4f4f4e5e5f5f4f4e5e5f5f4f4f4e5e5f5f4f4f4e5e5f5f4f4f5e5e5f4e4e4f4f4e5e5f5f4f4f4e4e4e4e5f4e4e4e5e5f5f4e5e5f5f4f4f5f4f4f4e4e4e5f4e4e4e4e4e5f4e4e4e5e5f5f4f4f5e5e5f4e5e5f5f4f4f4f4f4f4f4e4e5e5f5f4f4e5e5f5f4f4f5e5f5f4f4f4e4e5e5f5f4f4f4e4e5e5e4e5e5f5f4f4f
4e4e4e5f4e4e4e4e4e4e5f4e4e4e4e5f4e4e4e4e4e5f4e4e4e4e4e5f4e4e4e5e5f5f4f4f4e4e4e4e5f4e4e5e5e4e4e4e4e4e4e4e4e5f4e4e4e5f4e4e5f4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e4e4e5f4e4e4e5e5f4e4e4e5f4e4e4f4e4e4e4e4e4e4e5f4e4e4e4e5f4e4e4e4e5f4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e4e5f4e4e
4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e5e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e5e5e5e5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f4e4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4f4f4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5f4e4e4e
4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e5e5e5e5e4f4f4d4d5d5d5d5d4d5c5c5c5c4d4d5c5c4c4e4e4e5e4e5f5f4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e4f4e4e4e4f4e4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e5e5e5e5e4f4f5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c
4c444544454445444544454544453b4c4e5e4e5f5f4e4f4d3c616160616061606160616060615c4e4e4e5e5e5f4e4c3d636263626362636263626362634c4e4f4e4e4e4e4e4c3e656564656465646564646564654c4e5e4e5f5f4e4f5c666766676667666766676766676667666766676667666766666766676667666766675c
4c44455455545554555455444544454c4e5e5e5f4e4e4f4d70717170717071707170717070714d4e4e4e4e5e5f5f4c62636263727372737273637372734c4e4f4e4f4f4e4e4c74757574757475747574747574754c4e5e5e5f4e4e4f5c666766676667666766676667666766676667666766676667666766676667666766675c
4c54554544454445454445545554554c4e4e5e5f5f4f4f4d60616160616061606160616070714d4e4e4e4e4e4e5f4c72736263737262636263736362634c4e4f4f4f4e4e4e4c64656465646565747574757464654c4e4e5e5f5f4f4f5c767776777677767776777677767776777677767776777677767776777677767776775c
4c44455554555455454445444444454c4e4e4e5e5e4e4e4d70717170717071707170717060614d4e4e4e4e5e5e4e4c62637273626372737273727372734c4e4e4f4f4e4f4f4c74757475747575747564656474754c4e4e4e4e5f4e4e5c666766676667666766676667666766676667666766676667666766676667666766675c
4c54554544454445555455545454554c4e4e5e5e5e5e4e4d60616160616061606160616070715c4e4e4e5e5e4e5e4c62636263727362636263626362634c4e4e4e5e5e4e4e4c64657475747565646574756465654c4e4e4e4e4e4e4e5c767776776667767776777677767776777677666776777677767776776667767776775c
4c44455554555455454445444444454c4e4e5e4e5f5f4e4d70717170717071707170606160615c4e4e5e5e5e5e5f4c72736263727372737273727372734c4e4e5e5e5e5e4e4c74756465646575646564657475754c5e5e5e5e4f4f4e5c666766677677666766676667666766676667767766676667666766677677666766675c
4c54444544454445555455545454554c4e4e5e5e5f4e4e4d60616061606160616060707170714d4e4e5e4e5f5f4e4c62637273626362636263626362634c4e4e5e4e5f5f4e4c64657475747564656465756464654c5e4e5f5f4e4f4e5c767766676667666766676667666776776667666766676667767766676667666766675c
4c44545554554445444544454444454c4e4e4e5e5f5f4e4d70717071707170717070606160614d4e4e5e5e5f4e5f4c72736263726263626362636263734c4e4e5e5e5f4e4e4c74757475646574757475657474754c5e5e5f4e4e4f4e5c666776777677767776777677767766677677767776777677666776777677767776775c
__sfx__
000500000000015660156501264012640106201061000000000000000023600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b0201b0201b0201b0201b0401c0501e04021040260402b0402b0402a040190402405025060260601a0601506016060130600e0600b05008040060300503003020030200802010050290503a05000000
0001000034310283401d33012730107100e7200d7100d7100d7100c7100e7100f71012710147201b7301d7301f7302173024730277302a7302f73032730327302d7002c7002a50021500045000b5003d50000000
0001000006550045500355018500015001b50018500195001c5002d7002b70029700117002d500137002e5001c7002d7003370034500317001c7002c700327002a70000000000000000000000000000000000000
010500002575022750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b45030050000000000000000000000000000000000000000000000000000000037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c00000c0531a0003b655130000c053000003b655000000c053000003b655000000c0530c0533b6550c0530c053000003b655000000c053000003b655000000c053000003b655000000c053000003b6553b655
001a00000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c0000c0531a0003b6250c000
001a00000e050134301a35017140104301100015700210000e05011430144301713013450013001c700207000e050134301a35017140104301570015700210000e05011440144401716012420195001c70020700
001a0000217300c42012550134201773013420115500c420217300c4200a5500c42017730084200a5500842020730084200d5501042017730134201755017420217301742014550144202173012420155500d430
__music__
00 41424344
03 4c0b0d44
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 414b4344

