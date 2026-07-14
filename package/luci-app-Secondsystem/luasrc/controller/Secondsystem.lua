module("luci.controller.Secondsystem", package.seeall)

function index()
    entry({"admin", "system", "Secondsystem"}, alias("admin", "system", "Secondsystem", "settings"), _("第一系统"), 50)
    entry({"admin", "system", "Secondsystem", "settings"}, template("Secondsystem/settings"), _("系统切换"), 10)
    entry({"admin", "system", "Secondsystem", "switch"}, call("action_switch"), nil)
    entry({"admin", "system", "Secondsystem", "reboots"}, call("action_reboots"), nil)
end

function action_switch()
    local sys = require "luci.sys"
    local http = require "luci.http"
    local confirm = http.formvalue("confirm")
    
    if confirm and confirm == "yes" then
        local rc = sys.call("fw_setenv boot_system 0 >/dev/null 2>&1")
        if rc ~= 0 then
            http.status(500, "Failed to update boot environment")
            http.write("切换失败：无法写入 boot_system，请检查 u-boot 环境配置。")
            return
        end
        sys.call("logger -t Secondsystem 'boot_system=0, switching to the first system'")
        sys.call("(sleep 2; reboot) >/dev/null 2>&1 &")
        http.write("正在切换到第一系统并重启。")
    else
        luci.http.redirect(luci.dispatcher.build_url("admin", "system", "Secondsystem", "settings"))
    end
end

function action_reboots()
    local sys = require "luci.sys"
    local http = require "luci.http"
    local confirm = http.formvalue("confirm")
    
    if confirm and confirm == "yes" then
        sys.call("logger -t Secondsystem 'reboot requested from LuCI'")
        sys.call("(sleep 2; reboot) >/dev/null 2>&1 &")
        http.write("正在重启。")
    else
        luci.http.redirect(luci.dispatcher.build_url("admin", "system", "Secondsystem", "settings"))
    end
end
