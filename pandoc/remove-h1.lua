function Header(elem)
  if elem.level == 1 then
    return {}  -- 返回空表，意味着删除 h1
  end
  return elem
end
