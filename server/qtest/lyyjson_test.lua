local json = require("lyyjson")

do
    local double = 2 ^ 53
    print(json.encode(double))
    assert(json.encode(double)=="9007199254740992")
    assert(json.decode(json.encode(double))==double)
end

do
    local t1 = {}
    t1[4] = "d"
    t1[2] = "b"
    t1[3] = "c"
    t1[1] = "a"
    local str = json.encode(t1) --["a","b","c","d"]
    print(str)
    assert(string.sub(str,1,1)=="[")
    local t2 = json.decode(str)
    assert(#t2==4)
    assert(t2[1]=="a")
    assert(t2[2]=="b")
    assert(t2[3]=="c")
    assert(t2[4]=="d")
end

do
    local t1 = {[4] = "d", [2]="b", [3]="c", [1]="a"}
    local str = json.encode(t1) --["a","b","c","d"]
    print(str)
    assert(string.sub(str,1,1)=="[")
    local t2 = json.decode(str)
    assert(#t2==4)
    assert(t2[1]=="a")
    assert(t2[2]=="b")
    assert(t2[3]=="c")
    assert(t2[4]=="d")
end

do
    local t1 = {}
    table.insert(t1,"a")
    table.insert(t1,"b")
    table.insert(t1,"c")
    table.insert(t1,"d")
    local str = json.encode(t1) --["a","b","c","d"]
    print(str)
    assert(string.sub(str,1,1)=="[")
    local t2 = json.decode(str)
    assert(#t2==4)
    assert(t2[1]=="a")
    assert(t2[2]=="b")
    assert(t2[3]=="c")
    assert(t2[4]=="d")
end

do
    local t1 = {"a","b","c","d"}
    local str = json.encode(t1) --["a","b","c","d"]
    print(str)
    assert(string.sub(str,1,1)=="[")
    local t2 = json.decode(str)
    assert(#t2==4)
    assert(t2[1]=="a")
    assert(t2[2]=="b")
    assert(t2[3]=="c")
    assert(t2[4]=="d")
end

do
    local t1 = {"a","b",[5]="c","d", e={
        w = 1,
        x = 2
    }}
    local str = json.encode(t1) --{"1":"a","2":"b","3":"d","5":"c"}
    print(str)
    assert(string.sub(str,1,1)=="{")
    local t2 = json.decode(str)
    assert(t2[1]=="a")
    assert(t2[2]=="b")
    assert(t2[5]=="c")
    assert(t2[3]=="d")
    local str_f = json.pretty_encode(t1)
    print("format:",str_f)
end

do
    local t1 = {[1] = "a", [2] = "b",[100] = "c",}
    local str = json.encode(t1) --{"1":"a","2":"b","100":"c"}
    print(str)
    assert(string.sub(str,1,1)=="{")
    local t2 = json.decode(str)
    assert(t2[1]=="a")
    assert(t2[2]=="b")
    assert(t2[100]=="c")
end

do
    local t1 = {["a"]=1,["b"]=2,["c"] =3}
    local str = json.encode(t1) -- {"b":2,"c":3,"a":1}
    print(str)
    assert(string.sub(str,1,1)=="{")
    local t2 = json.decode(str)
    assert(t2["a"]==1)
    assert(t2["b"]==2)
    assert(t2["c"]==3)
end

do
    local t1 = {[100] = "a", [200] = "b",[300] = "c",}
    local str = json.encode(t1) -- {"300":"c","100":"a","200":"b"}
    print(str)
    assert(string.sub(str,1,1)=="{")
    local t2 = json.decode(str)
    assert(t2[100]=="a")
    assert(t2[200]=="b")
    assert(t2[300]=="c")
end

do
    local t1 = {["1.0"]=1,["2.0"]=2,["3.0"] =3}
    local str = json.encode(t1) --  {"1.0":1,"3.0":3,"2.0":2}
    print(str)
    assert(string.sub(str,1,1)=="{")
    local t2 = json.decode(str)
    assert(t2["1.0"]==1)
    assert(t2["2.0"]==2)
    assert(t2["3.0"]==3)
end

do
    local t1 = {["100abc"]="hello"}
    local str = json.encode(t1) --  {"100abc":"hello"}
    print(str)
    assert(string.sub(str,1,1)=="{")
    local t2 = json.decode(str)
    assert(t2["100abc"]=="hello")
end

do
    ---issue case: try convert string key to integer
    local t1 = {["1"]=1,["2"]=2,["3"] =3}
    local str = json.encode(t1) -- {"1":1,"2":2,"3":3}
    print(str)
    assert(string.sub(str,1,1)=="{","adadadad")
    local t2 = json.decode(str)
    assert(t2[1]==1)
    assert(t2[2]==2)
    assert(t2[3]==3)

    str = json.encode(t2) -- [1,2,3]
    assert(string.sub(str,1,1)=="[")
end

do
    local ok, err = xpcall(json.encode, debug.traceback, { a = function()
    end })
    assert(not ok, err)
end

do
    local t = {nil,nil,nil, 100}
    assert(string.sub(json.encode(t),1,1)=="[")
    assert(#json.decode(json.encode(t)) == 4)
    local t2 = json.decode(json.encode(t))
    assert(t2[1]==json.null)
    assert(t2[2]==json.null)
    assert(t2[3]==json.null)
    assert(t2[4]==100)
end