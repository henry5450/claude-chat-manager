#!/data/data/com.termux/files/usr/bin/sh
# 构建适用于 Termux (aarch64) 的 ClaudeChatManager
# 依赖: pkg install dotnet-sdk-10.0
#
# 说明: Termux 的 dotnet 是 bionic 构建 (RID: linux-bionic-arm64),
#   - 不支持 AOT (缺 Microsoft.NETCore.App.Runtime.AOT.linux-bionic-arm64 pack)
#   - single-file bundle 的 apphost patch 失效 (apphost 被 strip, bundler 写不进 bundle header)
# 因此采用 self-contained 目录发布 + 自解压脚本包装成单文件。
set -e

cd "$(dirname "$0")"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# 1. self-contained 目录发布
rm -rf dist dist-sf
dotnet publish ClaudeChatManager/ClaudeChatManager.csproj \
    -c Release \
    -r linux-bionic-arm64 \
    -p:PublishAot=false \
    -p:PublishSingleFile=false \
    --self-contained true \
    -o dist

# 删除运行时发布附带的无用静态库和调试符号, 运行只需要 .so 与 .dll
rm -f dist/*.a dist/*.pdb

# 2. 打包 payload
tar czf claude-chat-manager-termux-aarch64.tar.gz -C dist .

# 3. 拼接自解压单文件
# payload 起始偏移 = launcher 字节数 + 1 (等宽替换占位符, 替换前后脚本长度不变)
LEN=$(wc -c < launcher.sh)
OFFSET=$((LEN + 1))
OFFSET_STR=$(printf '%010d' "$OFFSET")
sed "s/^PAYLOAD_OFFSET=0000000000$/PAYLOAD_OFFSET=$OFFSET_STR/" launcher.sh > .launcher-gen.sh
cat .launcher-gen.sh claude-chat-manager-termux-aarch64.tar.gz > ClaudeChatManager-termux
rm -f .launcher-gen.sh
chmod +x ClaudeChatManager-termux

echo "构建完成:"
echo "  单文件: ClaudeChatManager-termux"
echo "  目录包: claude-chat-manager-termux-aarch64.tar.gz"
