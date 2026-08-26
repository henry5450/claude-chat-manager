#!/data/data/com.termux/files/usr/bin/bash
# ClaudeChatManager Termux 自解压启动器
# 首次运行把内嵌的发布目录解压到缓存, 之后直接启动
VERSION="1.0.1"
EXTRACT_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-chat-manager"
MARKER="$EXTRACT_DIR/.v$VERSION.ok"

if [ ! -f "$MARKER" ]; then
    rm -rf "$EXTRACT_DIR"
    mkdir -p "$EXTRACT_DIR" || exit 1
    # 定位本文件中的 payload (标记行之后的所有字节)
    OFFSET=$(grep -abo "^__PAYLOAD__$" "$0" 2>/dev/null | head -1 | cut -d: -f1)
    [ -n "$OFFSET" ] || exit 1
    OFFSET=$((OFFSET + 13))
    tail -c +"$OFFSET" "$0" | tar xz -C "$EXTRACT_DIR" || exit 1
    touch "$MARKER" || exit 1
fi

# 自包含运行, 避免受系统 dotnet 环境变量干扰
unset DOTNET_ROOT DOTNET_ROOT_ARM64 DOTNET_MULTILEVEL_LOOKUP
exec "$EXTRACT_DIR/ClaudeChatManager" "$@"
exit
__PAYLOAD__
