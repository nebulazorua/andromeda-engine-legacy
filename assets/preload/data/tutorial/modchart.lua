print(InternalSprite.a)
InternalSprite.a='asdasdasdasd'
print(InternalSprite.a)
print(getmetatable(InternalSprite))
InternalSprite:bruh("a","penis")
print(InternalSprite.a)
InternalSprite.a=2;
function create()
    print("create")
end

function beatHit(beat)
    print(beat)
end