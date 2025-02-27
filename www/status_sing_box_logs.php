<?php
$log_file = "/var/log/sing-box.log";

// 设置正确的 Content-Type
header('Content-Type: text/plain');

// 检查日志文件是否存在并可读
if (file_exists($log_file) && is_readable($log_file)) {
    // 获取最近的 200 行日志
    $lines = 200;
    $log_content = shell_exec("tail -n $lines " . escapeshellarg($log_file));
    echo $log_content;
} else {
    echo "日志文件不存在或无法读取。";
}