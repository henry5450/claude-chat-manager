using ClaudeChatManager;

// Ctrl+C 会触发 SIGINT 直接终止进程，跳过 Spectre.Console 在 finally 中恢复光标的逻辑，
// 导致终端光标消失。这里先恢复光标再退出。
Console.CancelKeyPress += (_, _) => Console.CursorVisible = true;

InteractiveUI.Run();
