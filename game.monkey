Strict

Import mojo


Const BOARD_W:Float = 500.0

Const BOARD_H:Float = 500.0
Const BAT_W:Float = 104.0
Const BAT_H:Float = 24.0
Const BALL_R:Float = 11.0
Const BRICK_W:Float = 64.0
Const BRICK_H:Float = 32.0
Const NROWS:Int = 4
Const NCOLS:Int = 5

Class Game Extends App

	Field batx:Float = 250.0
	
	Field prev_batx:Float = 25.0
		
	Field baty:Float = 450.0
	Field bat_img:Image
	Field ball:Ball
	Field bricks:Brick[NROWS*NCOLS]
	Field score:Int = 0
	Field cleared:Int = 0
	
	Field font_img:Image
	
	Field hit_sfx:Sound
	Field smash_sfx:Sound
	
	Method OnCreate:Int()
		SetUpdateRate(60)
		bat_img = LoadImage("bat.png", 1 , Image.MidHandle)
		ball = New Ball(250, 250)
		'brick = New Brick(100, 100, 2)
		For Local b:Int = 0 Until NROWS
			For Local r:Int = 0 Until NCOLS
				Local brk:Brick = New Brick(100 + r*BRICK_W, 100 + b*BRICK_H, Rnd(6))
				bricks[r + b*NCOLS] = brk
			End
		End
		
		hit_sfx = LoadSound("hit.wav")
		smash_sfx = LoadSound("smash.wav")
		font_img = LoadImage("font.png", 10)
		SetFont(font_img, 48)
		
		Return 0
	End

	Method OnUpdate:Int()
		
		prev_batx = batx
		If MouseX() > 0 batx = MouseX()
		ball.Update()
		
		If Abs(ball.posx - batx) < BAT_W/2 And Abs(ball.posy - baty) < BAT_H And ball.vely > 0 Then
			ball.vely *= -1.0
			PlaySound( hit_sfx)
			ball.velx += 0.25*(batx - prev_batx)
		End If
			
		For Local brick:Brick = Eachin bricks
			If Not brick.hidden
				Local yd:Float = Abs(ball.posy - brick.posy )
				Local xd:Float = Abs(ball.posx - brick.posx)
				
				If xd <= BRICK_W/2 + BALL_R And yd < BRICK_H/2
					ball.velx *= -1.0
					brick.hidden = True
					score += 100
					PlaySound( smash_sfx)
					cleared += 1
								
				Else If yd <= BRICK_H/2 + BALL_R And xd < BRICK_W/2
					ball.vely *= -1.0
					brick.hidden = True
					score += 100
					PlaySound( smash_sfx)
					cleared += 1
					
				End
			End
		End
			
		If cleared >= NROWS*NCOLS Then
			ResetBoard()
			score += 1000
			cleared = 0
		End
			
		If ball.posy > 470 Then
			ResetBoard()
			cleared = 0
			score = 0
			ball.posx = 250
			ball.posy = 250
			ball.velx = 0
			ball.vely = 4
		End
		
		Return 0
	End
	
	Method ResetBoard:Void()
		For Local brk:Brick = Eachin bricks
			brk.hidden = False
		End
	End

	Method OnRender:Int()
		Cls (80, 80, 80)
		DrawImage(bat_img, batx, baty)
		ball.Draw()
		'brick.Draw()
		For Local brk:Brick = Eachin bricks
			If brk And Not brk.hidden brk.Draw()
		End
		
		DrawText(score, 250, 40, 0.5, 0.5 )
		Return 0
	End

End

Class Ball
	Field posx:Float = 250.0
	Field posy:Float = 250.0
	Field velx:Float = 0.0
	Field vely:Float = 4.0
	Global ball_img:Image = Null
	
	Method New( x:Float, y:Float)
		posx = x
		posy = y
		If Not ball_img
			ball_img = LoadImage("ball.png", 1, Image.MidHandle)
		End If
	End
	
	Method Update:Void()
		 posx += velx
		 posy += vely
		 If posx > BOARD_W And velx > 0
		 	velx *= -1.0
		 End If
		 If posx < 0 And velx < 0
		 	velx *= -1.0
		 End If
		 
		If posy > BOARD_H And vely > 0
		 	vely *= -1.0
		 End If
		 If posy < 0 And vely < 0
		 	vely *= -1.0
		 End If
	End
	
	Method Draw:Void()
		
		DrawImage(ball_img, posx, posy)
	End
	
End

Class Brick
	Field posx:Float
	Field posy:Float
	Field colour:Int
	Field hidden:Bool = False
	Global bricks_img:Image

	Method New(x:Float, y:Float, c:Float)
		posx = x
		posy = y
		colour = c
		If Not bricks_img
			bricks_img = LoadImage("bricks.png")
		End If
	End
	Method Draw:Void()
		DrawImageRect(bricks_img, posx - BRICK_W/2, posy - BRICK_H/2, 0.0 , colour*BRICK_H, BRICK_W, BRICK_H)
	End
End

Function Main:Int()
    New Game()
	Return 0
End
