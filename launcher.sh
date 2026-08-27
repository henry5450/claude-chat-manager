#!/data/data/com.termux/files/usr/bin/sh
# ClaudeChatManager Termux 自解压启动器
# 首次运行把内嵌的发布目录解压到缓存, 之后直接启动
# 注意: PAYLOAD_OFFSET 是构建时写入的等宽占位符, 由 build-termux.sh 计算并替换,
# 运行时只需 tail + tar, 不依赖 grep/awk/sed 等工具变体
VERSION="1.0.3"
EXTRACT_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-chat-manager"
MARKER="$EXTRACT_DIR/.v$VERSION.ok"
PAYLOAD_OFFSET=0000000000

if [ ! -f "$MARKER" ]; then
    rm -rf "$EXTRACT_DIR"
    mkdir -p "$EXTRACT_DIR" || exit 1
    tail -c +"$PAYLOAD_OFFSET" "$0" | tar xz -C "$EXTRACT_DIR" || exit 1
    touch "$MARKER" || exit 1
fi

# 自包含运行, 避免受系统 dotnet 环境变量干扰
unset DOTNET_ROOT DOTNET_ROOT_ARM64 DOTNET_MULTILEVEL_LOOKUP
exec "$EXTRACT_DIR/ClaudeChatManager" "$@"
exit
__PAYLOAD__
