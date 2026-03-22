function transferFrom(address from, address to, uint256 tokenId) public {
    // 1. 安检：调用者必须是主人，或者得到了主人的授权
    require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
    // 2. 安检：房子必须确实是 from 的
    require(ownerOf(tokenId) == from, "Not the owner");
    // 3. 安检：不能转给黑洞
    require(to != address(0), "Transfer to zero address");

    // 【核心三步走 - 账本更新】
    
    // A. 清除旧的授权（房子换主人了，之前的中介授权自动作废）
    _approve(address(0), tokenId);

    // B. 更新房产总数（先减后加）
    _balances[from] -= 1;
    _balances[to] += 1;

    // C. 更改房产证名字（这是你刚才漏掉的！）
    _owners[tokenId] = to;

    // D. 发公告
    emit Transfer(from, to, tokenId);
}
