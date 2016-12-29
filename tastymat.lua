--[[A collection of functions for various matrix operations
not built into Lua. Written explicitly for learning and testing.]]

local tastymat = {}

require "math"
math.randomseed(1)

-- get matrix dimensions and print it
function tastymat.info(matrix)
  local m = matrix
  print(string.format("%sx%s matrix",table.getn(m),table.getn(m[1])))
  tastymat.pr(m)
end


-- create a lua table that will represent a matrix and fill it
function tastymat.matrix(rows, cols, mode)
  local rows = rows
  local cols = cols
  local fill = nil
  local m = {}
  -- fill the matrix with normal random numbers
  if mode == true then
    fill = math.random
  -- fill with zeros
  elseif mode == false then
    fill = function() return 0 end
  end
  for i=1,rows do
    m[i] = {}
    for j=1,cols do
      m[i][j] = fill()
    end
  end
  return m
end

-- compute exponential of a matrix element-wise
function tastymat.exp(matrix)
  local m = matrix
  for i=1,#m do
    for j=1,#m[i] do
      m[i][j] = math.exp(m[i][j])
    end
  end
  return m
end


-- pretty-print a lua table or matrix
function tastymat.pr(tabl)
  for i=1,#tabl do
    for j=1,#tabl[i] do
      io.write(tabl[i][j]..',')
    end
    io.write("\n")
  end
end

-- apply sigmoid function to a matrix element-wise
function tastymat.sigmoid(matrix)
  local m = matrix
  for i=1,#m do
    for j=1,#m[i] do
      m[i][j] = 1/(1+math.exp(-m[i][j]))
    end
  end
  return m
end

-- convert sigmoid function matrix to its derivative
function tastymat.sig2deriv(matrix)
  local m = matrix
  for i=1,#m do
    for j=1,#m[i] do
      m[i][j] = m[i][j]*(1-m[i][j])
    end
  end
  return m
end


--[[Perform math operation on a matrix element wise.
This function requires 3 args. First is the matrix itself.
Second is the math sign: *, +, /, -. Thirs is the number.
]]
function tastymat.matop(matrix, op, num)
  local m = matrix
  if op == '*' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = m[i][j] * num
      end
    end
    return m
  elseif op == '+' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = m[i][j] + num
      end
    end
    return m
  elseif op == '/' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = m[i][j] / num
      end
    end
    return m
  elseif op == '-' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = m[i][j] - num
      end
    end
    return m
  end
end

--[[Perform math operation on a matrix element wise.
This function requires 3 args. First is the number.
Second is the math sign: *, +, /, -. Third is the matrix.
]]
function tastymat.opmat(num, op, matrix)
  local m = matrix
  if op == '*' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = num * m[i][j]
      end
    end
    return m
  elseif op == '+' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = num + m[i][j]
      end
    end
    return m
  elseif op == '/' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = num / m[i][j]
      end
    end
    return m
  elseif op == '-' then
    for i=1,#m do
      for j=1,#m[i] do
        m[i][j] = num - m[i][j]
      end
    end
    return m
  end
end

-- perform matrix transpose
function tastymat.transpose(matrix)
  local m = matrix
  local t = {}
  for i=1,#m[1] do -- assuming matrix[1] not nil
    t[i] = {}
    for j=1,#m do
      t[i][j] = m[j][i]
    end
  end
  return t
end

-- flatten lua matrix
function tastymat.mat2arr(matrix)
  local m = matrix
  local c = {}
  for i=1,#m do
    for j=1,#m[i] do
      c[#c+1] = m[i][j]
    end
  end
  return c
end

-- perform matrix substaction
function tastymat.sub(matrix1, matrix2)
  local m1 = matrix1
  local m2 = matrix2
  -- check dimensions
  local m1rows = table.getn(m1)
  local m1cols = table.getn(m1[1])
  local m2rows = table.getn(m2)
  local m2cols = table.getn(m2[1])
  if not (m1rows == m2rows and m1cols == m2cols) then
    print("Matrix substaction error!")
    print(string.format("Bad dimensions: %sx%s,%sx%s",m1rows,m1cols,m2rows,m2cols))
    os.exit(1)
  end
  local c = {}
  -- element-wise substraction
  for i=1,#m1 do
    c[i] = {}
    for j=1,#m1[i] do
      c[i][j] = m1[i][j] - m2[i][j]
    end
  end
  return c
end

-- perform matrix addition
function tastymat.add(matrix1, matrix2)
  local m1 = matrix1
  local m2 = matrix2
  -- check dimensions
  local m1rows = table.getn(m1)
  local m1cols = table.getn(m1[1])
  local m2rows = table.getn(m2)
  local m2cols = table.getn(m2[1])
  if not (m1rows == m2rows and m1cols == m2cols) then
    print("Matrix addition error!")
    print(string.format("Bad dimensions: %sx%s,%sx%s",m1rows,m1cols,m2rows,m2cols))
    os.exit(1)
  end
  local c = {}
  -- element-wise substraction
  for i=1,#m1 do
    c[i] = {}
    for j=1,#m1[i] do
      c[i][j] = m1[i][j] + m2[i][j]
    end
  end
  return c
end

-- perform matrix multiplication
function tastymat.mul(matrix1, matrix2)
  local m1 = matrix1
  local m2 = matrix2
  -- check dimensions
  local m1rows = table.getn(m1)
  local m1cols = table.getn(m1[1])
  local m2rows = table.getn(m2)
  local m2cols = table.getn(m2[1])
  if not (m1rows == m2rows and m1cols == m2cols) then
    print("Matrix multiplication error!")
    print(string.format("Bad dimensions: %sx%s,%sx%s",m1rows,m1cols,m2rows,m2cols))
    os.exit(1)
  end
  local c = {}
  -- element-wise substraction
  for i=1,#m1 do
    c[i] = {}
    for j=1,#m1[i] do
      c[i][j] = m1[i][j] * m2[i][j]
    end
  end
  return c
end


-- perform matrix dot product
function tastymat.dot(matrix1, matrix2)
  local m1 = matrix1
  local m2 = matrix2
  -- check dimensions
  local m1rows = table.getn(m1)
  local m1cols = table.getn(m1[1])
  local m2rows = table.getn(m2)
  local m2cols = table.getn(m2[1])
  if m1cols ~= m2rows then
    print("Matrix dot product error!")
    print(string.format("Bad dimensions: %sx%s,%sx%s",m1rows,m1cols,m2rows,m2cols))
    os.exit(1)
  end
  -- init result matrix
  local m3 = tastymat.matrix(m1rows,m2cols,false)
  -- element-wise dot product
  for i=1,m1rows  do
    for j=1,m2cols do
      for k=1,m2rows do
        m3[i][j] = m3[i][j] + m1[i][k] * m2[k][j]
      end
    end
  end
  return m3
end

-- apply negation to matrix
function tastymat.neg(matrix)
  local m = matrix
  for i=1,#m do
    for j=1,#m[i] do
      m[i][j] = m[i][j] * -1
    end
  end
  return m
end

return tastymat
