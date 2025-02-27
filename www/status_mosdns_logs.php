<?php
// 获取 MosDNS 的日志内容
$log_file = "/var/log/mosdns.log"; // 假设 MosDNS 的日志文件路径
if (file_exists($log_file)) {
    echo file_get_contents($log_file);
} else {
    echo "日志文件未找到或无法访问。";
}
?>
