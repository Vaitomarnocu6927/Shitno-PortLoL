function onCreatePost()
    doTweenAlpha('GUItween', 'camHUD', 0, 0.1, 'linear');
    setProperty('gf.visible', false)
    setProperty('dad.alpha', 0)
    noteTweenAlpha('G',0,0,2.1,'Linear')
    noteTweenAlpha('H',1,0,2.1,'Linear')
    noteTweenAlpha('B',2,0,2.2,'Linear')
    noteTweenAlpha('D',3,0,2.3, 'linear')
    
    makeLuaSprite('bang','bang',-1000,-1000)
	makeGraphic('bang',2000,2000,'000000')
    addLuaSprite('bang',true)
    setScrollFactor('bang',1,1)
    doTweenZoom('in','camGame',1.2,1,'ExpoOut')


end

function onStepHit()
    if curStep == 1 then
    doTweenAlpha('bang', 'bang', 0, 4, 'linear')
    end

    if curStep == 415 then
     doTweenAlpha('Soulbf', 'dad', 1, 2, 'linear')
     doTweenAlpha('floor_shitno', 'floor_shitno', 1, 2, 'linear')
     doTweenX('boyfriend<y', 'boyfriend', 700, 2, 'ExpoInOut')
    end
end
