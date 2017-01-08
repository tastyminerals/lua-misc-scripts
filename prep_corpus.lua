--[[
Do not process big text files, it will trigger out of memory errors!
Split you corpus into smaller files "split -l 10000 raw_corpus.txt".
]]

local txt = require 'tastytxt'

-- corpus path
local cpath = '/home/tastyminerals/dev/thesis/rocstories_chunks'

-- read data files
print("reading files...")
local function preprocess(fpath)
    local text = txt.read(fpath)
    local ptext = txt.prep(text,false,true) -- default settings
    txt.write(ptext,string.gsub(fpath,".*/",'_'))
end

-- iterate through files and preprocess each
local files = txt.ls(cpath)
local left = #files
for i,f in next,files do
    print(string.format("processing (%d/%d) %s",left,i,f))
    preprocess(f)
end

