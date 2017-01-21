#!/usr/bin/env luajit
--[[
Compute and print text corpus stats.

Usage:
  corpus_stats.lua [fname]
  corpus_stats.lua [dirname] -- if corpus is split

Stats:
  file size
  number of tokens
  vocabulary size (number of unique tokens)
  number of punctuation tokens
  puncutation vocabulary size
  number of lines
  number of sentences
  number of singletons (rare words with freq=1)
  *average number of words per sentence
  *lexical diversity -- http://fredrikdeboer.com/2014/10/13/evaluating-the-comparability-of-two-measures-of-lexical-diversity/
  *number of nouns/verbs/adjectives/adverbs...
  *most frequent nouns/verb/adj/adverb...
  correctness
  *number of named netities
  *sentiment
  *subjectivity
  *word cloud
]]

pl = require "pl"
pretty = require "pl.pretty"
utf8 = require "lua-utf8"


function iop(str)
  io.write(string.format("%050s\r", ' '))
  io.write(str)
  io.flush()
end

function round(num, decimal)
  local mult = 10^(decimal or 0)
  return math.floor(num * mult + 0.5) / mult
end

function size(file)
  local f = io.open(file,'r')
  local current = f:seek()      -- get current position
  local size = f:seek("end")    -- get file size
  f:seek("set",current)        -- restore position
  f:close()
  return round(size/1024/1024,2)
end

function is_dir(path)
  local f = io.popen("test -d "..path.." && echo 1 || echo 0")
  if f:read(1) == '1' then
    f:close()
    return true
  end
  f:close()
  return false
end

-- if path contains files, return an array of file paths
function listdir(path)
    local i,files = 0,{}
    local pfile = io.popen('ls "'..path..'"')
    for fname in pfile:lines() do
        i = i + 1
        -- path must end on / or \
        fpath = path..'/'..fname
        files[i] = fpath
    end
    pfile:close()
    return files
end

function readfile(fname)
  local ifile = assert(io.open(fname, 'r'))
  local fdata = ifile:read("*all")
  ifile:close()
  return utf8.lower(fdata)
end

-- count the number of elements in a table
function cnt(tab)
  local cnt = 0
  for _ in pairs(tab) do
    cnt = cnt + 1
  end
  return cnt
end

--[[ text functions ]]--

-- count the number of tokens using str match
function cnt_tokens(text)
  local text = text
  -- separate punctuation from words first
  local _,cnt = utf8.gsub(tokenize(text),"%S+",'')
  return cnt
end

-- count only punctuation chars
function cnt_punk(text)
  local text = text
  -- separate punctuation from words first
  local _,cnt = utf8.gsub(tokenize(text),"%p",'')
  return cnt
end

function cnt_lines(text)
  local text = text
  local cnt = 0
  for _ in utf8.gmatch(text,"[^\n]+") do
    cnt = cnt + 1
  end
  return cnt
end

-- separate punctuation from text
function tokenize(text)
  local text = text
  local lns = {}
  -- iterate over each line, otherwise we are breaking text formatting
  for line in utf8.gmatch(text,"[^\n]+") do
    -- surround punctuation with spaces
    line = utf8.gsub(line,"(%p)"," %1 ")
    -- replace mult space with single space
    line = utf8.gsub(line,"%s%s+"," ")
    -- fix auxiliary contractions
    line = utf8.gsub(line," ' s "," 's ") -- for English
    line = utf8.gsub(line," ' t "," 't ") -- for English
    line = utf8.gsub(line," ' ve "," 've ") -- for English
    line = utf8.gsub(line," ' m "," 'm ") -- for English
    line = utf8.gsub(line," ' re "," 're ") -- for English
    line = utf8.gsub(line," ' d "," 'd ") -- for English
    line = utf8.gsub(line," ' ll "," 'll ") -- for English
    table.insert(lns,line)
  end
  return table.concat(lns,'\n')
end

-- return {punctuation=cnt} map
function vocab_punct(text)
  local pvocab = {}
  local text = tokenize(text)
  -- count tokens
  for punct in utf8.gmatch(text,"%p") do
    if pvocab[punct] then
      pvocab[punct] = pvocab[punct] + 1
    else
      pvocab[punct] = 1
    end
  end
  return pvocab
end


-- count tokens and return {token=cnt} map
function vocab(text)
  local vocab = {}
  local text = tokenize(text)
  -- count tokens
  for word in utf8.gmatch(text,"%S+") do
    if vocab[word] then
      vocab[word] = vocab[word] + 1
    else
      vocab[word] = 1
    end
  end
  return vocab
end

-- return {tokens} occurring <= max number of times
function rare(text,max)
  -- count tokens
  local wordmap = vocab(text)
  -- find singletons
  local singletons = {}
  for k,v in next,wordmap,nil do
    if v <= max then
      table.insert(singletons,k)
    end
  end
  --pretty.dump(singletons)
  return singletons
end

function cnt_sents(text)
  local text = text
  local sent_cnt = 0
  -- split into lines
  for line in utf8.gmatch(text,"[^\n]+") do
    for _ in utf8.gmatch(line, "[^%.%?%!]+[%.%!%?]+ ?") do
      sent_cnt = sent_cnt + 1
    end
  end
  return sent_cnt
end

-- return {tokens} occurring <= max number of times
function rare(vocab,max)
  local wordmap = vocab
  local max = max or 1
  -- find singletons
  local singletons = {}
  for k,v in next,wordmap,nil do
    if v <= max then
      table.insert(singletons,k)
    end
  end
  --pretty.dump(singletons)
  return singletons
end


local input = arg[1]
local stats = {}
local data

if is_dir(input) then
  local chunks = {}
  local mbs = 0
  local fdata
  for _,fpath in pairs(listdir(input)) do
    fdata = readfile(fpath)
    mbs = mbs + size(fpath)
    table.insert(chunks,fdata)
  end
  iop("calculating size...\r")
  stats.size_mb = mbs
  chunks = table.concat(chunks,"\n")
  data = tokenize(chunks)
else
  data = tokenize(readfile(input))
  iop("calculating size...\r")
  stats.size_mb = size(input)
end

iop("counting tokens...\r")
stats.total_tokens = cnt_tokens(data)
iop("calculating vocab...\r")
stats.vocab_size = cnt(vocab(data))
iop("counting punctuation chars...\r")
stats.punc_size = cnt_punk(data)
iop("calculating punctuation vocab...\r")
stats.vocab = vocab_punct(data)
stats.vocab_punct_size = cnt(stats.vocab)
iop("counting lines...\r")
stats.lines_cnt = cnt_lines(data)
iop("counting sentences...\r")
stats.sents_cnt = cnt_sents(data)
iop("counting single words...\r")
stats.singletons = cnt(rare(stats.vocab))

print("Name: "..input)
print("size (MB): "..stats.size_mb)
print("sentences: "..stats.sents_cnt)
print("lines: "..stats.lines_cnt)
print("total tokens: "..stats.total_tokens)
print("vocab size: "..stats.vocab_size)
print("singleton words: "..stats.singletons)
print("puntuation chars: "..stats.punc_size)
print("punctuation vocab: "..stats.vocab_punct_size)


