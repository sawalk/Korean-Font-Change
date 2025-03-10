KoreanFontChange = RegisterMod("Korean Font Change", 1)
local mod = KoreanFontChange

local font = Font()
local sprite = Sprite()

font:Load("font/cjk/lanapixel.fnt")
sprite:Load("lmao/yareyare.anm2", true)


------ 상수 및 상태 변수 ------
local RENDERING_TIME_THRESHOLD = 480    -- 애니메이션 시작까지 누적 렌더 프레임 수
local MAX_ANIM_FRAME = 88               -- 최대 애니메이션 프레임 번호
local SOUND_NAME = "Good Night Ojosama"
local soundId = Isaac.GetSoundIdByName(SOUND_NAME)

local animFrame = 1            -- 현재 애니메이션 프레임
local playAnimation = false
local displayedTime = 0        -- 렌더링 누적 시간
local renderCounter = 0        -- 애니메이션 업데이트용 렌더 프레임 카운터
local soundStarted = false

local animationFinished = false    -- 애니메이션 종료 여부
local textHideCounter = 0          -- 애니메이션 종료 후 텍스트 표시 시간 카운터
local textHidden = false           -- 텍스트 표시 여부


------ 유틸리티 ------
local function UpdateSpriteScale()
    local scale = Isaac.GetScreenPointScale()
    if scale == 1 then
        sprite.Scale = Vector(2, 2)
    elseif scale == 2 then
        if Options.Fullscreen then
            sprite.Scale = Vector(1, 1)
        else
            sprite.Scale = Vector(0.5, 0.5)
        end
    elseif scale == 3 then
        sprite.Scale = Vector(0.67, 0.67)
    else-- scale >= 4
        sprite.Scale = Vector(0.5, 0.5)
    end
end

local function RenderAnimation(animationName)
    sprite:Play(animationName)
    sprite:Update()
    UpdateSpriteScale()
    sprite:Render(Vector(10, 10))
end

local function DrawModText()
    local text1, text2, text3

    if animFrame > 4 then
        text1 = "'z Korean Font Change'는 리펜턴스+와 호환되지 않습니다."
        text2 = "아무튼 게임 켤 때마다 이거 보고 싶지 않으면"
        text3 = "모드를 끄는 것이 좋은 선택일 거예요 <3"
    else
        text1 = "'z Korean Font Change'는 리펜턴스+와 호환되지 않습니다."
        text2 = "모드를 끄고 게임을 재시작하세요."
        text3 = "지금 모드를 끄지 않으면 우린 춤을 출 거예요 <3"
    end

    font:DrawStringUTF8(text1, 72, 150, KColor(1,1,1,1), 0, true)
    font:DrawStringUTF8(text2, 72, 166, KColor(1,1,1,1), 0, true)
    font:DrawStringUTF8(text3, 72, 190, KColor(1,0,0,1), 0, true)
end


------ 렌더링 ------
mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, -20000000, function()
    if not REPENTANCE_PLUS then
        return
    end

    if not playAnimation then
        displayedTime = displayedTime + 1
        if displayedTime >= RENDERING_TIME_THRESHOLD then
            playAnimation = true
        end
    end

    if playAnimation and animFrame > MAX_ANIM_FRAME then
        if not animationFinished then
            SFXManager():Stop(soundId)
            Game():GetHUD():SetVisible(true)
            animationFinished = true
        else
            textHideCounter = textHideCounter + 1
            if textHideCounter >= 300 then
                textHidden = true
            end
        end

        if not textHidden then
            DrawModText()
        end
        return
    end

    if not textHidden then
        DrawModText()
    end

    if playAnimation then
        if not soundStarted then
            SFXManager():Play(soundId)
            Game():GetHUD():SetVisible(false)
            soundStarted = true
        end

        renderCounter = renderCounter + 1
        if renderCounter % 6 == 0 then
            animFrame = animFrame + 1
        end

        local newSheet = string.format("lmao/scene/scene%d.png", animFrame)
        sprite:ReplaceSpritesheet(0, newSheet)
        sprite:LoadGraphics()
        RenderAnimation("mot mallineun")
    end
end)
