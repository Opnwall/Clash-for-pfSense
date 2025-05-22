<?php
require_once("guiconfig.inc");

$pgtitle = [gettext('VPN'), gettext('订阅管理')];
include("head.inc");

// 配置文件路径
define('ENV_FILE', '/usr/local/etc/clash/sub/env');
define('LOG_FILE', '/var/log/sub.log');

// 使用 pfSense 的选项卡函数生成菜单
$tab_array = [
    1 => [gettext("Clash"), false, "services_clash.php"],
    2 => [gettext("MosDNS"), false, "services_mosdns.php"],	
    3 => [gettext("Sub"), true, "sub.php"],
];

display_top_tabs($tab_array);

/**
 * 记录日志
 * @param string $message 日志内容
 * @param string $log_file 日志文件路径
 */
function log_message($message, $log_file = LOG_FILE) {
    $time = date("Y-m-d H:i:s");
    $log_entry = "[{$time}] {$message}\n";
    file_put_contents($log_file, $log_entry, FILE_APPEND | LOCK_EX);
}

/**
 * 清空日志文件
 * @param string $log_file 日志文件路径
 */
function clear_log($log_file = LOG_FILE) {
    file_put_contents($log_file, '', LOCK_EX);
}

/**
 * 保存环境变量到文件
 * @param string $key 变量名
 * @param string $value 变量值
 * @param string $env_file 环境文件路径
 * @return bool 是否保存成功
 */
function save_env_variable($key, $value, $env_file = ENV_FILE) {
    if (empty($key) || empty($value)) return false;

    $lines = file_exists($env_file) ? file($env_file, FILE_IGNORE_NEW_LINES) : [];
    $new_lines = [];
    foreach ($lines as $line) {
        if (!preg_match("/^export {$key}=.*$/", $line)) {
            $new_lines[] = $line;
        }
    }
    $new_lines[] = "export {$key}='{$value}'";
    try {
        file_put_contents($env_file, implode("\n", $new_lines) . "\n", LOCK_EX);
        return true;
    } catch (Exception $e) {
        error_log("环境变量保存失败: " . $e->getMessage());
        return false;
    }
}

/**
 * 加载环境变量
 * @param string $env_file 环境文件路径
 * @return array 包含所有环境变量的数组
 */
function load_env_variables($env_file = ENV_FILE) {
    $env_vars = [];
    if (file_exists($env_file)) {
        $env_lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($env_lines as $line) {
            if (strpos($line, 'export ') === 0) {
                list($key, $value) = explode('=', substr($line, 7), 2);
                $env_vars[$key] = trim($value, "'\"");
            }
        }
    }
    return $env_vars;
}

// 加载当前订阅地址和密钥
$env_vars = load_env_variables();
$current_url = $env_vars['CLASH_URL'] ?? '';
$current_secret = $env_vars['CLASH_SECRET'] ?? '';

// 处理表单提交
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['save'])) {
        $url = trim($_POST['subscribe_url']);
        $secret = trim($_POST['clash_secret']);

        // 清空日志文件
        clear_log();

        // 保存订阅地址和安全密钥
        $url_saved = save_env_variable('CLASH_URL', $url);
        $secret_saved = save_env_variable('CLASH_SECRET', $secret);

        // 记录日志
        if ($url_saved) {
            log_message("订阅地址已保存：{$url}");
        } else {
            echo "<div class='alert alert-danger'>保存订阅地址失败！</div>";
        }

        if ($secret_saved) {
            log_message("安全密钥已保存。");
        } else {
            echo "<div class='alert alert-danger'>保存安全密钥失败！</div>";
        }

        // 刷新页面
        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }

    if (isset($_POST['action']) && $_POST['action'] === '立即订阅') {
        // 清空日志文件
        clear_log();

        // 执行订阅操作并记录日志
        $cmd = escapeshellcmd("/usr/bin/sub");
        exec($cmd . " >> " . LOG_FILE . " 2>&1", $output_lines, $return_var);
        $output = implode("\n", $output_lines);
        log_message("订阅操作执行完毕。");
    }
}

// 读取日志文件内容
$log_content = file_exists(LOG_FILE) ? htmlspecialchars(file_get_contents(LOG_FILE)) : '';
?>

<!-- 页面表单 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h2 class="panel-title">Clash 订阅管理</h2>
    </div>
    <div class="panel-body">
        <form method="post">
            <div class="form-group">
                <label for="subscribe_url">订阅地址：</label>
                <input type="text" id="subscribe_url" name="subscribe_url" value="<?php echo htmlspecialchars($current_url); ?>" class="form-control" placeholder="输入订阅地址" autocomplete="off" />
            </div>
            <div class="form-group">
                <label for="clash_secret">访问密钥：</label>
                <input type="text" id="clash_secret" name="clash_secret" value="<?php echo htmlspecialchars($current_secret); ?>" class="form-control" placeholder="输入安全密钥" autocomplete="off" />
                <button type="submit" name="save" class="btn btn-primary"><i class="fa fa-save"></i> 保存设置</button>
                <button type="submit" name="action" value="立即订阅" class="btn btn-success" /><i class="fa fa-sync"></i> 开始订阅</button>
            </div>
        </form>
    </div>
</div>

<!-- 实时日志显示 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h2 class="panel-title">实时日志</h2>
    </div>
    <div class="form-group">
        <textarea name="log_content" rows="20" class="form-control"><?php echo $log_content; ?></textarea>
    </div>
</div>

<?php
include("foot.inc");
?>