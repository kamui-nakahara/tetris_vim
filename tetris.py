import random
import pygame
import sys
import json
f=open("blocks2.json")
blocks={}
block_types=json.load(f)
block_type=random.choice(block_types)
rotate=0
block=block_type[rotate]
colors=[(0,0,255),(0,255,0),(0,255,255),(255,0,0),(255,0,255),(255,255,0),(255,255,255)]
color=random.choice(colors)
x=250
y=-100
count=0
score=0
pause=True
gameover=False
pygame.init()
font=pygame.font.Font(None,50)
screen=pygame.display.set_mode((500,800))
pygame.display.set_caption("テトリス")
while True:
    for event in pygame.event.get():
        if event.type==pygame.QUIT:
            sys.exit()
        elif event.type==pygame.KEYDOWN:
            if event.key==pygame.K_ESCAPE:
                sys.exit()
            elif event.key==pygame.K_RETURN:
                if not gameover:
                    pause=not pause
            elif event.key==pygame.K_UP:
                flag=True
                for i in block_type[(rotate-1)%len(block_type)]:
                    if (i[0]+x,i[1]+y) in blocks or not (0<=i[0]+x<=450 and 0<=i[1]+y<=750):
                        flag=False
                if flag:
                    rotate=(rotate-1)%len(block_type)
                    block=block_type[rotate]
            elif event.key==pygame.K_DOWN:
                flag=True
                for i in block_type[(rotate+1)%len(block_type)]:
                    if (i[0]+x,i[1]+y) in blocks or not (0<=i[0]+x<=450 and 0<=i[1]+y<=750):
                        flag=False
                if flag:
                    rotate=(rotate+1)%len(block_type)
                    block=block_type[rotate]
            elif event.key==pygame.K_LEFT:
                if block[1][0]+x!=0:
                    flag=True
                    for i in block:
                        if (i[0]+x-50,i[1]+y) in blocks:
                            flag=False
                            break
                    if flag:x-=50
            elif event.key==pygame.K_RIGHT:
                if block[-1][0]+x!=450:
                    flag=True
                    for i in block:
                        if (i[0]+x+50,i[1]+y) in blocks:
                            flag=False
                            break
                    if flag:x+=50
            elif event.key==pygame.K_SPACE:
                pass
    screen.fill((0,0,0))
    for i in range(50,500,50):
        pygame.draw.line(screen,(255,255,255),(i,0),(i,800),5)
    for i in range(50,800,50):
        pygame.draw.line(screen,(255,255,255),(0,i),(500,i),5)
    if not pause:
        if count%150==0:
            y+=50
            flag=False
            for i in block:
                if i[1]+y==750 or (i[0]+x,i[1]+y+50) in blocks:
                    flag=True
                    break
            if flag:
                for i in block:
                    blocks[(i[0]+x,i[1]+y)]=color
                block_type=random.choice(block_types)
                rotate=0
                block=block_type[rotate]
                color=random.choice(colors)
                x=250
                y=-100
                yy=750
                while yy>-50:
                    qua=0
                    for xx in range(0,500,50):
                        if (xx,yy) in blocks:
                            if yy==0:
                                gameover=True
                                pause=True
                                break
                            qua+=1
                    if qua==10:
                        for xx in range(0,500,50):
                            del blocks[(xx,yy)]
                            for yyy in range(yy,-50,-50):
                                if (xx,yyy) in blocks:
                                    blocks[(xx,yyy+50)]=blocks[(xx,yyy)]
                                    del blocks[(xx,yyy)]
                        score+=1
                    else:
                        yy-=50
    for i in block:
        pygame.draw.rect(screen,color,(i[0]+x,i[1]+y,50,50))
    for i in blocks:
        pygame.draw.rect(screen,blocks[i],(*i,50,50))
    score_text=font.render(str(score),True,(255,0,0))
    screen.blit(score_text,(0,0))
    if gameover:
        gameover_text=font.render("gameover",False,(255,0,0),(0,0,0))
        rect=gameover_text.get_rect()
        rect.center=(250,400)
        screen.blit(gameover_text,rect)
    pygame.display.update()
    count+=1
